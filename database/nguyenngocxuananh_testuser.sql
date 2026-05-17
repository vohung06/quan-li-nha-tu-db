--Test 1: Test quyền xem bảng thân nhân của user
SELECT * FROM THANNHAN; -- -> ổn nó xem được 
--Test 2: Test quyền xem bảng lịch thăm nuôi của user 
SELECT * FROM LICHTHAMNUOI; -- -> ổn nó xem được 
--Test 3: Test user có coi bảng khác không
SELECT * FROM TUNHAN; -- -> ổn nó không xem được 
--Test 4: Test user có thêm được hay không 
INSERT INTO LICHTHAMNUOI (MaLich, MaTuNhan, MaThanNhan, NgayHen, TrangThai, GhiChu)
VALUES ('L999', 'TN001', 'TN01', '2026-06-01', N'Chưa duyệt', N'Test thử quyền');
-- -> ổn nó không thêm được 
--Test 5: Test user có sửa được hay không 
UPDATE LICHTHAMNUOI SET TrangThai = N'Đã duyệt'
WHERE MaLich = 'L001';
-- -> ổn nó không sửa được 
--Test 6: Test user có xóa được hay không 
DELETE FROM THANNHAN 
WHERE MaThanNhan = 'TN01';
--> ổn nó không thể xóa được 


