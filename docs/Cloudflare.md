Các thay đổi chính:
Thêm disown để giữ tiến trình:
disown $PORT_FORWARD_PID và disown $TUNNEL_PID đảm bảo kubectl port-forward và cloudflared không bị dừng khi script kết thúc.
Tăng thời gian chờ:
Tăng sleep 5 thành sleep 10 sau khi tạo tunnel để đảm bảo tunnel sẵn sàng.
Thêm cơ chế thử lại:
Thêm vòng lặp để thử kết nối tối đa 3 lần, mỗi lần cách nhau 5 giây.
Sử dụng --logfile cho cloudflared:
Thêm --logfile cloudflared.log để đảm bảo log được ghi đúng.
Lưu PID:
Lưu PID của kubectl port-forward và cloudflared vào file tạm (/tmp/port_forward_pid.txt và /tmp/cloudflared_pid.txt) để quản lý sau này.

Check Tiếng việt 
```bash
kubectl exec -it $(kubectl get pod -l app=mysql -n default -o jsonpath='{.items[0].metadata.name}') -n default -- mysql -uroot -prootpass

SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```