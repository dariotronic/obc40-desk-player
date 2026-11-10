"""Inoltra 127.0.0.1:8888 del PC al server di login di Desk Player sulla scheda.

Serve perché l'sshd di Alpine ha AllowTcpForwarding disattivato: ogni connessione
diventa un comando `ssh ... nc 127.0.0.1 8888` eseguito sulla scheda.

Uso:
    python login-tunnel.py <ip-scheda> [--user obc] [--key ~/.ssh/chiave]
Poi aprire http://127.0.0.1:8888 nel browser del PC. Ctrl+C per chiudere.
Requisiti sul PC: Python 3 e il client OpenSSH (`ssh` nel PATH), accesso SSH alla scheda.
"""
import argparse
import os
import socket
import subprocess
import threading

ap = argparse.ArgumentParser(description="Tunnel per il login Spotify di Desk Player")
ap.add_argument("host", help="IP (o nome) della scheda")
ap.add_argument("--user", default="obc", help="utente SSH sulla scheda (predefinito: obc)")
ap.add_argument("--key", default=None,
                help="chiave SSH privata (senza: si usa la configurazione SSH predefinita)")
ap.add_argument("--port", type=int, default=8888)
args = ap.parse_args()

SSH = ["ssh", "-o", "BatchMode=yes"]
if args.key and os.path.exists(os.path.expanduser(args.key)):
    SSH += ["-i", os.path.expanduser(args.key)]
SSH += [f"{args.user}@{args.host}", f"nc 127.0.0.1 {args.port}"]


def pump(src_read, dst_write, close):
    try:
        while True:
            data = src_read(65536)
            if not data:
                break
            dst_write(data)
    except OSError:
        pass
    finally:
        close()


def handle(conn):
    p = subprocess.Popen(SSH, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    def to_ssh(data):
        p.stdin.write(data)
        p.stdin.flush()

    def close_in():
        try:
            p.stdin.close()
        except OSError:
            pass

    def close_conn():
        try:
            conn.shutdown(socket.SHUT_WR)
        except OSError:
            pass

    t = threading.Thread(target=pump, args=(conn.recv, to_ssh, close_in), daemon=True)
    t.start()
    pump(p.stdout.read1, conn.sendall, close_conn)
    t.join(timeout=2)
    conn.close()
    p.kill()


# verifica preliminare: la scheda risponde e Desk Player è in ascolto?
check = subprocess.run(SSH[:-1] + [f"printf 'GET / HTTP/1.0\\r\\n\\r\\n' | nc 127.0.0.1 {args.port} | head -1"],
                       capture_output=True, text=True, timeout=30)
if "200" not in check.stdout:
    raise SystemExit("La scheda non risponde o Desk Player non è avviato (aprilo sul display e riprova).\n"
                     + check.stderr.strip())

srv = socket.socket()
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(("127.0.0.1", args.port))
srv.listen(8)
print(f"Tunnel attivo: apri http://127.0.0.1:{args.port} nel browser (Ctrl+C per chiudere)", flush=True)
while True:
    c, _ = srv.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
