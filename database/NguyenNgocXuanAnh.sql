--Cau 4: Stored Procedure - Tìm danh sách tù nhân theo giới tính 
CREATE PROC sp_gioitinh_select @GioiTinh NVARCHAR(5)
AS BEGIN 
	SELECT MaTuNhan, SoCCCD, HoTen, GioiTinh
	FROM TUNHAN
	WHERE GioiTinh = @GioiTinh 
END;

sp_gioitinh_select Nữ;
sp_gioitinh_select Nam;

--Cau 4: Stored Procedure - Tìm thông tin tù nhân ở tù sớm nhất 
CREATE PROC sp_tunhan_select 
AS BEGIN 
	DECLARE @max int;
	SELECT @max = max(datediff(year, NgayBatDauThiHanhAn, getdate()))
	FROM BANAN 
	WHERE NgayBatDauThiHanhAn IS NOT NULL;
	SELECT TN.MaTuNhan, SoCCCD, HoTen, NgaySinh, GioiTinh, BA.NgayBatDauThiHanhAn
	FROM TUNHAN TN
	JOIN BANAN BA ON BA.MaTuNhan = TN.MaTuNhan
	WHERE datediff(year, NgayBatDauThiHanhAn, getdate()) = @max 
END;

sp_tunhan_select;

--Cau 4: Function - Tìm những quản ngục có mức lương cao hơn mức lương cần tìm
