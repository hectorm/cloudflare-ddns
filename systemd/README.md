# Install Systemd service and timer units

```sh
sudo cp cloudflare-ddns.{service,timer} /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/cloudflare-ddns.{service,timer}
sudo systemctl daemon-reload
sudo systemctl enable cloudflare-ddns.timer
sudo systemctl start cloudflare-ddns.timer
```
