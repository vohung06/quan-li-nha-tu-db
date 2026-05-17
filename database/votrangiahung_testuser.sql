USE QLNT;

SELECT * 
FROM TUNHAN;

BEGIN TRAN
INSERT INTO TUNHAN([MaTuNhan], [SoCCCD], [HoTen], [NgaySinh], [GioiTinh], [DiaChi], [NgayXuatTrai], [MaPhong], [TrangThai], [MucDoNguyHiem], [GhiChu])
VALUES
('TN031','066091234567',N'Tr?n Minh ??c','1993-10-21',N'Nam',N'Thôn 5, Xã Ea Kly, Huy?n Krông P?c, ??k L?k',NULL,'PC101',N'Ch? xét x?',N'Th?p',NULL);
SELECT *
FROM TUNHAN;
ROLLBACK;

BEGIN TRAN
INSERT INTO [QUANNGUC] ([MaQuanNguc], [TenQuanNguc], [NgaySinh], [GioiTinh], [DiaChi], [SoDienThoai], [Email], [MaKV], [NgayNhanChuc], [Luong], [ChucVu], [TrangThai])
VALUES
('QN21',N'Nguy?n Th? Mai','1985-03-12',N'N?',N'Ph??ng L?c Th?, TP. Nha Trang, Khánh Hòa','0982746153','mai.nguyen@prison.vn','KVA','2016-04-18',12500000,N'Tr??ng khu A',N'?ang làm');
ROLLBACK;
