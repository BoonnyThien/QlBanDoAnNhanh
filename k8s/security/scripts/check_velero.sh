echo "🚀 10 Kiểm tra Backup..."
echo "🔹 Velero Pods:"
kubectl get pods -n velero
echo "🔹 Backups:"
velero backup get
echo "🔹 Chi tiết backup doannhanh-backup:"
velero backup describe doannhanh-backup
echo "🔹 Thử khôi phục backup (dry-run):"
velero restore create test-restore --from-backup doannhanh-backup --dry-run
echo ""