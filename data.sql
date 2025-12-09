-- Skrip SQL untuk Sistem Manajemen Karyawan & Layanan Lapangan

-- Buat database
CREATE DATABASE IF NOT EXISTS employee_management;
USE employee_management;

-- Set karakter set untuk support Unicode
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET collation_connection = 'utf8mb4_unicode_ci';

-- Tabel Karyawan
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL,
    role ENUM('admin', 'technician', 'hr') DEFAULT 'technician',
    allowances DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Absensi
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    check_in DATETIME,
    check_out DATETIME,
    location VARCHAR(255),
    gps_coordinates VARCHAR(100),
    status ENUM('present', 'late', 'absent') DEFAULT 'present',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_date (employee_id, DATE(check_in))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Tiket Layanan
CREATE TABLE tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(20) UNIQUE,
    employee_id INT,
    customer_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'failed') DEFAULT 'pending',
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_employee_status (employee_id, status),
    INDEX idx_status_assigned (status, assigned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Potongan Gaji
CREATE TABLE deductions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    type ENUM('late', 'ticket', 'loan') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason TEXT NOT NULL,
    date DATE NOT NULL,
    ticket_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE SET NULL,
    INDEX idx_employee_date (employee_id, date),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Pinjaman Karyawan
CREATE TABLE employee_loans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    request_date DATE DEFAULT CURRENT_DATE,
    approval_date DATE,
    status ENUM('pending', 'approved', 'repaid') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_status (employee_id, status),
    INDEX idx_status_date (status, request_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel GPS Tracking
CREATE TABLE gps_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('on_duty', 'off_duty') DEFAULT 'off_duty',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_time (employee_id, recorded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel KPI
CREATE TABLE kpi_points (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    points INT DEFAULT 0,
    reason TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_date (employee_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Notifikasi
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    data TEXT,
    is_read BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_employee_type (employee_id, type, is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Pengaturan
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Hari Libur
CREATE TABLE holidays (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_holiday_date (date),
    INDEX idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel Log Sistem
CREATE TABLE system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    action VARCHAR(255) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_employee_time (employee_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tambahkan data awal untuk pengaturan
INSERT INTO settings (setting_key, value) VALUES
('company_name', 'PT. Teknologi Indonesia'),
('office_address', 'Jl. Teknologi No. 1, Jakarta'),
('office_lat', '-6.2088'),
('office_lng', '106.8456'),
('geofence_radius', '100'),
('late_threshold', '2'),
('ticket_deduction', '50'),
('working_days', '26'),
('default_base_salary', '2500000'),
('default_allowances', '500000');

-- Tambahkan data awal untuk hari libur
INSERT INTO holidays (date, name) VALUES
('2024-01-01', 'Tahun Baru Masehi'),
('2024-05-01', 'Hari Buruh'),
('2024-06-01', 'Hari Raya Idul Fitri'),
('2024-12-25', 'Hari Natal');

-- Tambahkan data contoh untuk karyawan
INSERT INTO employees (name, email, password, base_salary, role, allowances) VALUES
('Admin System', 'admin@company.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 5000000, 'admin', 1000000),
('John Doe', 'john.doe@company.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 2500000, 'technician', 500000),
('Jane Smith', 'jane.smith@company.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 2500000, 'technician', 500000),
('HR Manager', 'hr.manager@company.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 3000000, 'hr', 750000);

-- Tambahkan data contoh untuk tiket
INSERT INTO tickets (ticket_number, employee_id, customer_name, location, description, status, assigned_at) VALUES
('TKT202401010001', 2, 'PT. Teknologi Indonesia', 'Jl. Teknologi No. 1, Jakarta', 'Instalasi jaringan LAN baru', 'completed', '2024-01-01 08:00:00'),
('TKT202401010002', 3, 'CV. Digital Solution', 'Jl. Raya Pusat No. 10, Surabaya', 'Perbaikan router', 'in_progress', '2024-01-01 09:30:00'),
('TKT202401010003', 2, 'PT. Global Corp', 'Jl. Business Park No. 5, Tangerang', 'Upgrade sistem keamanan', 'pending', '2024-01-01 10:00:00'),
('TKT202401010004', 3, 'PT. Inovasi Digital', 'Jl. Teknologi Baru No. 3, Bandung', 'Instalasi CCTV', 'completed', '2024-01-01 11:00:00'),
('TKT202401010005', 2, 'CV. Komputindo', 'Jl. Komputer No. 7, Yogyakarta', 'Perbaikan server', 'failed', '2024-01-01 14:00:00');

-- Tambahkan data contoh untuk absensi
INSERT INTO attendance (employee_id, check_in, check_out, location, status) VALUES
(2, '2024-01-01 08:15:00', '2024-01-01 17:30:00', 'Jl. Teknologi No. 1, Jakarta', 'present'),
(3, '2024-01-01 09:45:00', '2024-01-01 18:00:00', 'Jl. Raya Pusat No. 10, Surabaya', 'present'),
(2, '2024-01-02 08:30:00', '2024-01-02 17:45:00', 'Jl. Teknologi No. 1, Jakarta', 'present'),
(3, '2024-01-02 09:00:00', '2024-01-02 17:30:00', 'Jl. Raya Pusat No. 10, Surabaya', 'present'),
(2, '2024-01-03 09:00:00', '2024-01-03 18:00:00', 'Jl. Teknologi No. 1, Jakarta', 'late');

-- Tambahkan data contoh untuk potongan gaji
INSERT INTO deductions (employee_id, type, amount, reason, date, ticket_id) VALUES
(2, 'ticket', 12038.25, 'Tiket #TKT202401010005 gagal diselesaikan', '2024-01-01', 5),
(2, 'late', 2407.65, 'Terlambat 2.5 jam pada 2024-01-03', '2024-01-03', NULL);

-- Tambahkan data contoh untuk pinjaman
INSERT INTO employee_loans (employee_id, amount, request_date, approval_date, status) VALUES
(2, 500000, '2024-01-01', '2024-01-02', 'approved'),
(3, 300000, '2024-01-02', '2024-01-03', 'approved'),
(2, 200000, '2024-01-03', NULL, 'pending');

-- Tambahkan data contoh untuk GPS tracking
INSERT INTO gps_tracking (employee_id, latitude, longitude, recorded_at, status) VALUES
(2, -6.2088, 106.8456, '2024-01-01 08:00:00', 'on_duty'),
(2, -6.2088, 106.8456, '2024-01-01 17:00:00', 'off_duty'),
(3, -7.2575, 112.7521, '2024-01-01 09:00:00', 'on_duty'),
(3, -7.2575, 112.7521, '2024-01-01 17:00:00', 'off_duty'),
(2, -6.2088, 106.8456, '2024-01-02 08:00:00', 'on_duty'),
(2, -6.2088, 106.8456, '2024-01-02 17:00:00', 'off_duty'),
(3, -7.2575, 112.7521, '2024-01-02 09:00:00', 'on_duty'),
(3, -7.2575, 112.7521, '2024-01-02 17:00:00', 'off_duty'),
(2, -6.2088, 106.8456, '2024-01-03 09:00:00', 'on_duty'),
(2, -6.2088, 106.8456, '2024-01-03 17:00:00', 'off_duty');

-- Tambahkan data contoh untuk KPI
INSERT INTO kpi_points (employee_id, points, reason, date) VALUES
(2, 5, 'Selesai 5 tiket dengan baik', '2024-01-01'),
(3, 3, 'Selesai 3 tiket dengan baik', '2024-01-01'),
(2, 2, 'Dapatkan 2 pelanggan baru', '2024-01-02'),
(3, 1, 'Dapatkan 1 pelanggan baru', '2024-01-02');

-- Tambahkan data contoh untuk notifikasi
INSERT INTO notifications (employee_id, type, message, data, is_read) VALUES
(2, 'new_ticket', 'Anda mendapatkan tiket baru', '{"ticket_id": 3, "customer": "PT. Global Corp"}', 0),
(3, 'new_ticket', 'Anda mendapatkan tiket baru', '{"ticket_id": 4, "customer": "PT. Inovasi Digital"}', 0),
(2, 'checkin_reminder', 'Pengingat: Waktu check-in mendekati', 'Check-in sebelum 08:00', 0),
(2, 'payroll_announcement', 'Pengumuman: Slip gaji bulan Januari 2024 telah dipersiapkan', 'Silakan cek dashboard', 0);

-- Tambahkan data contoh untuk log sistem
INSERT INTO system_logs (employee_id, action, details) VALUES
(1, 'user_login', 'Admin login'),
(2, 'user_login', 'John Doe login'),
(3, 'user_login', 'Jane Smith login'),
(1, 'ticket_created', 'Tiket #TKT202401010001 dibuat'),
(2, 'ticket_completed', 'Tiket #TKT202401010001 selesai'),
(3, 'ticket_assigned', 'Tiket #TKT202401010002 dialokasikan'),
(2, 'loan_approved', 'Pinjaman Rp 500.000 disetujui'),
(3, 'loan_approved', 'Pinjaman Rp 300.000 disetujui');

-- Buat view untuk laporan gaji bulanan
CREATE VIEW monthly_salary_report AS
SELECT 
    e.id AS employee_id,
    e.name AS employee_name,
    e.base_salary,
    e.allowances,
    COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) AS completed_tickets,
    COUNT(DISTINCT CASE WHEN t.status = 'failed' THEN t.id END) AS failed_tickets,
    SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) AS late_deductions,
    SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) AS ticket_deductions,
    SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END) AS loan_deductions,
    (e.base_salary + e.allowances) - 
    (SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) + 
     SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) + 
     SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END)) AS net_salary,
    MONTH(t.assigned_at) AS month,
    YEAR(t.assigned_at) AS year
FROM employees e
LEFT JOIN tickets t ON e.id = t.employee_id AND t.status IN ('completed', 'failed') AND MONTH(t.assigned_at) = MONTH(CURRENT_DATE()) AND YEAR(t.assigned_at) = YEAR(CURRENT_DATE())
LEFT JOIN deductions d ON e.id = d.employee_id AND MONTH(d.date) = MONTH(CURRENT_DATE()) AND YEAR(d.date) = YEAR(CURRENT_DATE())
GROUP BY e.id, e.name, e.base_salary, e.allowances, MONTH(t.assigned_at), YEAR(t.assigned_at);

-- Buat trigger untuk otomatisasi
DELIMITER //

-- Trigger untuk log sistem saat karyawan login
CREATE TRIGGER log_user_login
AFTER LOGIN ON employees
FOR EACH ROW
BEGIN
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (NEW.id, 'user_login', CONCAT('User ', NEW.name, ' logged in'));
END//

-- Trigger untuk log sistem saat tiket dibuat
CREATE TRIGGER log_ticket_creation
AFTER INSERT ON tickets
FOR EACH ROW
BEGIN
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (NEW.employee_id, 'ticket_created', CONCAT('Tiket #', NEW.ticket_number, ' created for ', NEW.customer_name));
END//

-- Trigger untuk log sistem saat tiket selesai
CREATE TRIGGER log_ticket_completion
AFTER UPDATE ON tickets
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        INSERT INTO system_logs (employee_id, action, details)
        VALUES (NEW.employee_id, 'ticket_completed', CONCAT('Tiket #', NEW.ticket_number, ' completed'));
    END IF;
END//

-- Trigger untuk log sistem saat pinjaman disetujui
CREATE TRIGGER log_loan_approval
AFTER UPDATE ON employee_loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        INSERT INTO system_logs (employee_id, action, details)
        VALUES (NEW.employee_id, 'loan_approved', CONCAT('Loan Rp ', NEW.amount, ' approved'));
    END IF;
END//

DELIMITER ;

-- Procedur untuk menghitung gaji bulanan
DELIMITER //

CREATE PROCEDURE calculate_monthly_salary(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    DECLARE v_daily_salary DECIMAL(10,2);
    DECLARE v_working_days INT;
    DECLARE v_base_salary DECIMAL(10,2);
    DECLARE v_allowances DECIMAL(10,2);
    DECLARE v_total_deductions DECIMAL(10,2);
    DECLARE v_net_salary DECIMAL(10,2);
    
    -- Ambil data karyawan
    SELECT base_salary, allowances INTO v_base_salary, v_allowances 
    FROM employees WHERE id = p_employee_id;
    
    -- Hitung gaji pokok harian
    SET v_daily_salary = v_base_salary / (SELECT value FROM settings WHERE setting_key = 'working_days');
    
    -- Hitung jumlah hari kerja
    SET v_working_days = (
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT DATE(assigned_at) as work_date
            FROM tickets
            WHERE employee_id = p_employee_id
            AND status = 'completed'
            AND MONTH(assigned_at) = p_month
            AND YEAR(assigned_at) = p_year
        ) AS work_days
    );
    
    -- Hitung total potongan
    SET v_total_deductions = (
        SELECT COALESCE(SUM(amount), 0)
        FROM deductions
        WHERE employee_id = p_employee_id
        AND MONTH(date) = p_month
        AND YEAR(date) = p_year
    );
    
    -- Hitung gaji bersih
    SET v_net_salary = (v_daily_salary * v_working_days + v_allowances) - v_total_deductions;
    
    -- Insert ke tabel payroll (jika ada)
    INSERT INTO payroll_reports (employee_id, month, year, base_salary, allowances, total_deductions, net_salary)
    VALUES (p_employee_id, p_month, p_year, v_base_salary, v_allowances, v_total_deductions, v_net_salary);
    
    -- Return hasil
    SELECT v_base_salary AS base_salary, v_allowances AS allowances, 
           v_total_deductions AS total_deductions, v_net_salary AS net_salary;
END//

DELIMITER ;

-- Tabel untuk laporan payroll
CREATE TABLE payroll_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL,
    allowances DECIMAL(10,2) NOT NULL,
    total_deductions DECIMAL(10,2) NOT NULL,
    net_salary DECIMAL(10,2) NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE KEY unique_payroll_period (employee_id, month, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Buat fungsi untuk validasi geofencing
DELIMITER //

CREATE FUNCTION validate_geofence(p_latitude DECIMAL(10,8), p_longitude DECIMAL(11,8)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_office_lat DECIMAL(10,8);
    DECLARE v_office_lng DECIMAL(11,8);
    DECLARE v_radius INT;
    DECLARE v_distance DECIMAL(10,2);
    
    -- Ambil data pengaturan
    SELECT value INTO v_office_lat FROM settings WHERE setting_key = 'office_lat';
    SELECT value INTO v_office_lng FROM settings WHERE setting_key = 'office_lng';
    SELECT value INTO v_radius FROM settings WHERE setting_key = 'geofence_radius';
    
    -- Hitung jarak
    SET v_distance = SQRT(POW(69.1 * (p_latitude - v_office_lat), 2) + POW(69.1 * (p_longitude - v_office_lng), 2) * POW(COS(RADIANS(v_office_lat / 57.3)), 2));
    
    -- Return hasil validasi
    RETURN v_distance <= v_radius;
END//

DELIMITER ;

-- Buat fungsi untuk menghitung keterlambatan
DELIMITER //

CREATE FUNCTION calculate_late_hours(p_check_in DATETIME, p_official_start TIME) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_late_minutes INT;
    DECLARE v_late_hours DECIMAL(5,2);
    
    -- Hitung selisih menit
    SET v_late_minutes = TIMESTAMPDIFF(MINUTE, 
        CONCAT(DATE(p_check_in), ' ', p_official_start), 
        p_check_in);
    
    -- Konversi ke jam
    SET v_late_hours = v_late_minutes / 60;
    
    -- Return hasil, 0 jika tidak terlambat
    RETURN IF(v_late_hours > 0, v_late_hours, 0);
END//

DELIMITER ;

-- Buat fungsi untuk menghitung potongan tiket
DELIMITER //

CREATE FUNCTION calculate_ticket_deduction(p_employee_id INT, p_date DATE) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_daily_salary DECIMAL(10,2);
    DECLARE v_deduction_percentage DECIMAL(5,2);
    DECLARE v_failed_tickets INT;
    DECLARE v_deduction_amount DECIMAL(10,2);
    
    -- Ambil data pengaturan
    SELECT value INTO v_daily_salary FROM settings WHERE setting_key = 'default_base_salary';
    SELECT value INTO v_deduction_percentage FROM settings WHERE setting_key = 'ticket_deduction';
    
    -- Hitung tiket gagal
    SET v_failed_tickets = (
        SELECT COUNT(*) 
        FROM tickets 
        WHERE employee_id = p_employee_id 
        AND status = 'failed' 
        AND DATE(assigned_at) = p_date
    );
    
    -- Hitung potongan
    SET v_deduction_amount = (v_daily_salary * v_deduction_percentage / 100) * v_failed_tickets;
    
    RETURN v_deduction_amount;
END//

DELIMITER ;

-- Buat view untuk dashboard admin
CREATE VIEW admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM employees) AS total_employees,
    (SELECT COUNT(*) FROM tickets WHERE status = 'pending') AS pending_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'in_progress') AS in_progress_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'completed') AS completed_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'failed') AS failed_tickets,
    (SELECT COUNT(*) FROM employee_loans WHERE status = 'pending') AS pending_loans,
    (SELECT COUNT(*) FROM employee_loans WHERE status = 'approved') AS approved_loans,
    (SELECT COUNT(*) FROM employee_loans WHERE status = 'repaid') AS repaid_loans,
    (SELECT COUNT(*) FROM attendance WHERE DATE(check_in) = CURDATE()) AS today_attendance,
    (SELECT COUNT(*) FROM notifications WHERE is_read = 0) AS unread_notifications;

-- Buat view untuk riwayat absensi
CREATE VIEW attendance_history AS
SELECT
    a.id,
    e.name AS employee_name,
    a.check_in,
    a.check_out,
    a.location,
    a.gps_coordinates,
    a.status,
    TIMESTAMPDIFF(HOUR, a.check_in, a.check_out) AS work_hours,
    calculate_late_hours(a.check_in, '08:00') AS late_hours,
    a.created_at
FROM attendance a
JOIN employees e ON a.employee_id = e.id
ORDER BY a.check_in DESC;

-- Buat view untuk riwayat tiket
CREATE VIEW ticket_history AS
SELECT
    t.id,
    t.ticket_number,
    e.name AS technician_name,
    t.customer_name,
    t.location,
    t.description,
    t.status,
    t.assigned_at,
    t.completed_at,
    t.created_at
FROM tickets t
LEFT JOIN employees e ON t.employee_id = e.id
ORDER BY t.assigned_at DESC;

-- Buat view untuk laporan potongan gaji
CREATE VIEW deduction_report AS
SELECT
    e.name AS employee_name,
    d.type,
    d.amount,
    d.reason,
    d.date,
    d.created_at
FROM deductions d
JOIN employees e ON d.employee_id = e.id
ORDER BY d.date DESC, d.created_at DESC;

-- Buat view untuk laporan pinjaman
CREATE VIEW loan_report AS
SELECT
    e.name AS employee_name,
    l.amount,
    l.request_date,
    l.approval_date,
    l.status,
    l.created_at
FROM employee_loans l
JOIN employees e ON l.employee_id = e.id
ORDER BY l.status, l.request_date DESC;

-- Buat view untuk laporan KPI
CREATE VIEW kpi_report AS
SELECT
    e.name AS employee_name,
    k.points,
    k.reason,
    k.date,
    k.created_at
FROM kpi_points k
JOIN employees e ON k.employee_id = e.id
ORDER BY k.date DESC, k.created_at DESC;

-- Buat view untuk laporan notifikasi
CREATE VIEW notification_report AS
SELECT
    e.name AS employee_name,
    n.type,
    n.message,
    n.data,
    n.is_read,
    n.created_at
FROM notifications n
LEFT JOIN employees e ON n.employee_id = e.id
ORDER BY n.created_at DESC;

-- Buat view untuk laporan pengaturan
CREATE VIEW settings_report AS
SELECT
    setting_key,
    value,
    created_at,
    updated_at
FROM settings
ORDER BY setting_key;

-- Buat view untuk laporan hari libur
CREATE VIEW holiday_report AS
SELECT
    id,
    date,
    name,
    created_at
FROM holidays
ORDER BY date DESC;

-- Buat view untuk laporan log sistem
CREATE VIEW system_log_report AS
SELECT
    e.name AS employee_name,
    l.action,
    l.details,
    l.created_at
FROM system_logs l
LEFT JOIN employees e ON l.employee_id = e.id
ORDER BY l.created_at DESC;

-- Buat view untuk laporan payroll
CREATE VIEW payroll_report AS
SELECT
    e.name AS employee_name,
    pr.month,
    pr.year,
    pr.base_salary,
    pr.allowances,
    pr.total_deductions,
    pr.net_salary,
    pr.generated_at
FROM payroll_reports pr
JOIN employees e ON pr.employee_id = e.id
ORDER BY pr.year DESC, pr.month DESC;

-- Buat stored procedure untuk export data
DELIMITER //

CREATE PROCEDURE export_data(IN p_table_name VARCHAR(50), IN p_format VARCHAR(10))
BEGIN
    DECLARE v_query TEXT;
    
    IF p_format = 'csv' THEN
        SET v_query = CONCAT('SELECT * INTO OUTFILE "/tmp/', p_table_name, '.csv" 
                           FIELDS TERMINATED BY "," 
                           ENCLOSED BY "\'" 
                           LINES TERMINATED BY "\n" 
                           FROM ', p_table_name);
    ELSEIF p_format = 'excel' THEN
        SET v_query = CONCAT('SELECT * FROM ', p_table_name);
        -- Logika export Excel bisa ditambahkan di sini
    END IF;
    
    PREPARE stmt FROM v_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;

-- Buat stored procedure untuk import data
DELIMITER //

CREATE PROCEDURE import_data(IN p_table_name VARCHAR(50), IN p_file_path VARCHAR(255))
BEGIN
    DECLARE v_query TEXT;
    
    SET v_query = CONCAT('LOAD DATA INFILE "', p_file_path, '" 
                       INTO TABLE ', p_table_name, ' 
                       FIELDS TERMINATED BY "," 
                       ENCLOSED BY "\'" 
                       LINES TERMINATED BY "\n"');
    
    PREPARE stmt FROM v_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;

-- Buat stored procedure untuk generate slip gaji
DELIMITER //

CREATE PROCEDURE generate_payslip(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    DECLARE v_employee_name VARCHAR(100);
    DECLARE v_base_salary DECIMAL(10,2);
    DECLARE v_allowances DECIMAL(10,2);
    DECLARE v_total_deductions DECIMAL(10,2);
    DECLARE v_net_salary DECIMAL(10,2);
    
    -- Ambil data karyawan
    SELECT name, base_salary, allowances INTO v_employee_name, v_base_salary, v_allowances
    FROM employees WHERE id = p_employee_id;
    
    -- Hitung potongan
    SET v_total_deductions = (
        SELECT COALESCE(SUM(amount), 0)
        FROM deductions
        WHERE employee_id = p_employee_id
        AND MONTH(date) = p_month
        AND YEAR(date) = p_year
    );
    
    -- Hitung gaji bersih
    SET v_net_salary = v_base_salary + v_allowances - v_total_deductions;
    
    -- Insert ke tabel payslips (jika ada)
    INSERT INTO payslips (employee_id, employee_name, month, year, base_salary, allowances, total_deductions, net_salary)
    VALUES (p_employee_id, v_employee_name, p_month, p_year, v_base_salary, v_allowances, v_total_deductions, v_net_salary);
    
    -- Return hasil
    SELECT v_employee_name AS employee_name, v_base_salary AS base_salary, 
           v_allowances AS allowances, v_total_deductions AS total_deductions, 
           v_net_salary AS net_salary;
END//

DELIMITER ;

-- Tabel untuk slip gaji
CREATE TABLE payslips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL,
    allowances DECIMAL(10,2) NOT NULL,
    total_deductions DECIMAL(10,2) NOT NULL,
    net_salary DECIMAL(10,2) NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE KEY unique_payslip (employee_id, month, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Buat view untuk slip gaji
CREATE VIEW payslip_view AS
SELECT
    p.id,
    p.employee_id,
    p.employee_name,
    p.month,
    p.year,
    p.base_salary,
    p.allowances,
    p.total_deductions,
    p.net_salary,
    p.generated_at
FROM payslips p
ORDER BY p.year DESC, p.month DESC;

-- Buat stored procedure untuk notifikasi massal
DELIMITER //

CREATE PROCEDURE send_mass_notification(IN p_type VARCHAR(50), IN p_message TEXT, IN p_data TEXT)
BEGIN
    DECLARE v_employee_id INT;
    
    -- Ambil semua karyawan
    DECLARE employee_cursor CURSOR FOR
    SELECT id FROM employees WHERE role = 'technician';
    
    -- Buka cursor
    OPEN employee_cursor;
    
    -- Loop melalui semua karyawan
    read_loop: LOOP
        FETCH employee_cursor INTO v_employee_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Insert notifikasi
        INSERT INTO notifications (employee_id, type, message, data)
        VALUES (v_employee_id, p_type, p_message, p_data);
    END LOOP;
    
    -- Tutup cursor
    CLOSE employee_cursor;
END//

DELIMITER ;

-- Buat stored procedure untuk update pengaturan
DELIMITER //

CREATE PROCEDURE update_setting(IN p_key VARCHAR(100), IN p_value TEXT)
BEGIN
    UPDATE settings SET value = p_value WHERE setting_key = p_key;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'setting_updated', CONCAT('Setting ', p_key, ' updated to ', p_value));
END//

DELIMITER ;

-- Buat stored procedure untuk tambah hari libur
DELIMITER //

CREATE PROCEDURE add_holiday(IN p_date DATE, IN p_name VARCHAR(100))
BEGIN
    INSERT INTO holidays (date, name) VALUES (p_date, p_name);
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'holiday_added', CONCAT('Holiday added: ', p_name, ' on ', p_date));
END//

DELIMITER ;

-- Buat stored procedure untuk hapus hari libur
DELIMITER //

CREATE PROCEDURE delete_holiday(IN p_id INT)
BEGIN
    DECLARE v_name VARCHAR(100);
    
    -- Ambil nama hari libur
    SELECT name INTO v_name FROM holidays WHERE id = p_id;
    
    -- Hapus hari libur
    DELETE FROM holidays WHERE id = p_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'holiday_deleted', CONCAT('Holiday deleted: ', v_name));
END//

DELIMITER ;

-- Buat stored procedure untuk assign tiket
DELIMITER //

CREATE PROCEDURE assign_ticket(IN p_ticket_id INT, IN p_employee_id INT)
BEGIN
    UPDATE tickets SET employee_id = p_employee_id WHERE id = p_ticket_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'ticket_assigned', CONCAT('Ticket #', p_ticket_id, ' assigned to employee ', p_employee_id));
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (p_employee_id, 'new_ticket', 'Anda mendapatkan tiket baru', 
            JSON_OBJECT('ticket_id', p_ticket_id));
END//

DELIMITER ;

-- Buat stored procedure untuk complete tiket
DELIMITER //

CREATE PROCEDURE complete_ticket(IN p_ticket_id INT, IN p_status VARCHAR(20), IN p_notes TEXT, IN p_photo_path VARCHAR(255))
BEGIN
    DECLARE v_employee_id INT;
    
    -- Ambil employee ID
    SELECT employee_id INTO v_employee_id FROM tickets WHERE id = p_ticket_id;
    
    -- Update tiket
    UPDATE tickets SET status = p_status, completed_at = NOW() WHERE id = p_ticket_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (v_employee_id, 'ticket_completed', CONCAT('Ticket #', p_ticket_id, ' completed with status ', p_status));
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (v_employee_id, 'ticket_completed', 'Tiket Anda telah selesai', 
            JSON_OBJECT('ticket_id', p_ticket_id, 'status', p_status));
    
    -- Tambahkan potongan jika tiket gagal
    IF p_status = 'failed' THEN
        CALL add_ticket_deduction(p_ticket_id);
    END IF;
END//

DELIMITER ;

-- Buat stored procedure untuk tambah potongan tiket
DELIMITER //

CREATE PROCEDURE add_ticket_deduction(IN p_ticket_id INT)
BEGIN
    DECLARE v_employee_id INT;
    DECLARE v_deduction_amount DECIMAL(10,2);
    DECLARE v_ticket_date DATE;
    
    -- Ambil data tiket
    SELECT employee_id, DATE(assigned_at) INTO v_employee_id, v_ticket_date FROM tickets WHERE id = p_ticket_id;
    
    -- Hitung potongan
    SET v_deduction_amount = calculate_ticket_deduction(v_employee_id, v_ticket_date);
    
    -- Insert potongan
    INSERT INTO deductions (employee_id, type, amount, reason, date, ticket_id)
    VALUES (v_employee_id, 'ticket', v_deduction_amount, 
            CONCAT('Tiket #', p_ticket_id, ' gagal diselesaikan'), v_ticket_date, p_ticket_id);
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'deduction_added', CONCAT('Ticket deduction added for ticket #', p_ticket_id, ': Rp ', v_deduction_amount));
END//

DELIMITER ;

-- Buat stored procedure untuk approve loan
DELIMITER //

CREATE PROCEDURE approve_loan(IN p_loan_id INT)
BEGIN
    UPDATE employee_loans SET status = 'approved', approval_date = NOW() WHERE id = p_loan_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'loan_approved', CONCAT('Loan approved: ID ', p_loan_id));
    
    -- Kirim notifikasi
    DECLARE v_employee_id INT;
    SELECT employee_id INTO v_employee_id FROM employee_loans WHERE id = p_loan_id;
    
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (v_employee_id, 'loan_approved', 'Pinjaman Anda telah disetujui', 
            JSON_OBJECT('loan_id', p_loan_id));
END//

DELIMITER ;

-- Buat stored procedure untuk mark loan as repaid
DELIMITER //

CREATE PROCEDURE mark_loan_repaid(IN p_loan_id INT)
BEGIN
    UPDATE employee_loans SET status = 'repaid', repayment_date = NOW() WHERE id = p_loan_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'loan_repaid', CONCAT('Loan repaid: ID ', p_loan_id));
    
    -- Kirim notifikasi
    DECLARE v_employee_id INT;
    SELECT employee_id INTO v_employee_id FROM employee_loans WHERE id = p_loan_id;
    
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (v_employee_id, 'loan_repaid', 'Pinjaman Anda telah lunas', 
            JSON_OBJECT('loan_id', p_loan_id));
END//

DELIMITER ;

-- Buat stored procedure untuk check-in
DELIMITER //

CREATE PROCEDURE employee_check_in(IN p_employee_id INT, IN p_latitude DECIMAL(10,8), IN p_longitude DECIMAL(11,8))
BEGIN
    DECLARE v_status VARCHAR(20);
    
    -- Validasi geofencing
    IF validate_geofence(p_latitude, p_longitude) THEN
        SET v_status = 'present';
    ELSE
        SET v_status = 'absent';
    END IF;
    
    -- Insert absensi
    INSERT INTO attendance (employee_id, check_in, location, gps_coordinates, status)
    VALUES (p_employee_id, NOW(), 'Office Location', CONCAT(p_latitude, ',', p_longitude), v_status);
    
    -- Update status GPS
    INSERT INTO gps_tracking (employee_id, latitude, longitude, recorded_at, status)
    VALUES (p_employee_id, p_latitude, p_longitude, NOW(), 'on_duty');
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (p_employee_id, 'check_in', CONCAT('Check-in at ', NOW(), ' with status ', v_status));
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (p_employee_id, 'checkin_success', 'Check-in berhasil', 
            JSON_OBJECT('status', v_status, 'time', NOW()));
END//

DELIMITER ;

-- Buat stored procedure untuk check-out
DELIMITER //

CREATE PROCEDURE employee_check_out(IN p_employee_id INT)
BEGIN
    -- Update absensi
    UPDATE attendance SET check_out = NOW(), status = 'completed' 
    WHERE employee_id = p_employee_id AND check_out IS NULL AND DATE(check_in) = CURDATE();
    
    -- Update status GPS
    INSERT INTO gps_tracking (employee_id, latitude, longitude, recorded_at, status)
    VALUES (p_employee_id, NULL, NULL, NOW(), 'off_duty');
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (p_employee_id, 'check_out', 'Check-out at ' || NOW());
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (p_employee_id, 'checkout_success', 'Check-out berhasil', 
            JSON_OBJECT('time', NOW()));
END//

DELIMITER ;

-- Buat stored procedure untuk add KPI points
DELIMITER //

CREATE PROCEDURE add_kpi_points(IN p_employee_id INT, IN p_points INT, IN p_reason TEXT)
BEGIN
    INSERT INTO kpi_points (employee_id, points, reason, date)
    VALUES (p_employee_id, p_points, p_reason, CURDATE());
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (p_employee_id, 'kpi_added', CONCAT('KPI points added: ', p_points, ' for ', p_reason));
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (p_employee_id, 'kpi_added', 'Anda mendapatkan poin KPI', 
            JSON_OBJECT('points', p_points, 'reason', p_reason));
END//

DELIMITER ;

-- Buat stored procedure untuk create ticket
DELIMITER //

CREATE PROCEDURE create_ticket(IN p_customer_name VARCHAR(100), IN p_location VARCHAR(255), 
                             IN p_description TEXT, IN p_employee_id INT)
BEGIN
    DECLARE v_ticket_number VARCHAR(20);
    
    -- Generate ticket number
    SET v_ticket_number = CONCAT('TKT', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND() * 1000), 4, '0'));
    
    -- Insert tiket
    INSERT INTO tickets (ticket_number, employee_id, customer_name, location, description, status)
    VALUES (v_ticket_number, p_employee_id, p_customer_name, p_location, p_description, 'pending');
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (p_employee_id, 'ticket_created', CONCAT('Ticket created: ', v_ticket_number));
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (p_employee_id, 'new_ticket', 'Anda mendapatkan tiket baru', 
            JSON_OBJECT('ticket_number', v_ticket_number, 'customer', p_customer_name));
END//

DELIMITER ;

-- Buat stored procedure untuk update employee
DELIMITER //

CREATE PROCEDURE update_employee(IN p_id INT, IN p_name VARCHAR(100), IN p_email VARCHAR(100), 
                              IN p_base_salary DECIMAL(10,2), IN p_role VARCHAR(20), IN p_allowances DECIMAL(10,2))
BEGIN
    UPDATE employees SET 
        name = p_name,
        email = p_email,
        base_salary = p_base_salary,
        role = p_role,
        allowances = p_allowances,
        updated_at = NOW()
    WHERE id = p_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'employee_updated', CONCAT('Employee updated: ID ', p_id));
END//

DELIMITER ;

-- Buat stored procedure untuk delete employee
DELIMITER //

CREATE PROCEDURE delete_employee(IN p_id INT)
BEGIN
    DELETE FROM employees WHERE id = p_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'employee_deleted', CONCAT('Employee deleted: ID ', p_id));
END//

DELIMITER ;

-- Buat stored procedure untuk create employee
DELIMITER //

CREATE PROCEDURE create_employee(IN p_name VARCHAR(100), IN p_email VARCHAR(100), 
                              IN p_password VARCHAR(255), IN p_base_salary DECIMAL(10,2), 
                              IN p_role VARCHAR(20), IN p_allowances DECIMAL(10,2))
BEGIN
    INSERT INTO employees (name, email, password, base_salary, role, allowances)
    VALUES (p_name, p_email, p_password, p_base_salary, p_role, p_allowances);
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'employee_created', CONCAT('Employee created: ', p_name));
END//

DELIMITER ;

-- Buat stored procedure untuk get dashboard stats
DELIMITER //

CREATE PROCEDURE get_dashboard_stats(IN p_employee_id INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND DATE(check_in) = CURDATE()) AS today_attendance,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'pending' AND DATE(assigned_at) = CURDATE()) AS pending_tickets,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'in_progress' AND DATE(assigned_at) = CURDATE()) AS in_progress_tickets,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'completed' AND DATE(assigned_at) = CURDATE()) AS completed_tickets,
        (SELECT SUM(points) FROM kpi_points WHERE employee_id = p_employee_id) AS total_kpi_points,
        (SELECT base_salary FROM employees WHERE id = p_employee_id) AS base_salary,
        (SELECT allowances FROM employees WHERE id = p_employee_id) AS allowances;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee stats
DELIMITER //

CREATE PROCEDURE get_employee_stats(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        e.base_salary,
        e.allowances,
        COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) AS completed_tickets,
        COUNT(DISTINCT CASE WHEN t.status = 'failed' THEN t.id END) AS failed_tickets,
        SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) AS late_deductions,
        SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) AS ticket_deductions,
        SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END) AS loan_deductions,
        (e.base_salary + e.allowances) - 
        (SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END)) AS net_salary
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND t.status IN ('completed', 'failed') AND MONTH(t.assigned_at) = p_month AND YEAR(t.assigned_at) = p_year
    LEFT JOIN deductions d ON e.id = d.employee_id AND MONTH(d.date) = p_month AND YEAR(d.date) = p_year
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, e.base_salary, e.allowances;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket details
DELIMITER //

CREATE PROCEDURE get_ticket_details(IN p_ticket_id INT)
BEGIN
    SELECT
        t.*,
        e.name AS technician_name,
        e.email AS technician_email,
        e.phone AS technician_phone
    FROM tickets t
    LEFT JOIN employees e ON t.employee_id = e.id
    WHERE t.id = p_ticket_id;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee details
DELIMITER //

CREATE PROCEDURE get_employee_details(IN p_employee_id INT)
BEGIN
    SELECT
        e.*,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = e.id) AS total_tickets,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = e.id AND status = 'completed') AS completed_tickets,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = e.id AND status = 'failed') AS failed_tickets,
        (SELECT SUM(points) FROM kpi_points WHERE employee_id = e.id) AS total_kpi_points,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = e.id) AS total_attendance
    FROM employees e
    WHERE e.id = p_employee_id;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance report
DELIMITER //

CREATE PROCEDURE get_attendance_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        a.*,
        TIMESTAMPDIFF(HOUR, a.check_in, a.check_out) AS work_hours,
        calculate_late_hours(a.check_in, '08:00') AS late_hours
    FROM attendance a
    WHERE a.employee_id = p_employee_id AND a.check_in BETWEEN p_start_date AND p_end_date
    ORDER BY a.check_in DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket report
DELIMITER //

CREATE PROCEDURE get_ticket_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        t.*,
        TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at) AS completion_time
    FROM tickets t
    WHERE t.employee_id = p_employee_id AND t.assigned_at BETWEEN p_start_date AND p_end_date
    ORDER BY t.assigned_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction report
DELIMITER //

CREATE PROCEDURE get_deduction_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        d.*,
        t.ticket_number,
        t.customer_name
    FROM deductions d
    LEFT JOIN tickets t ON d.ticket_id = t.id
    WHERE d.employee_id = p_employee_id AND d.date BETWEEN p_start_date AND p_end_date
    ORDER BY d.date DESC, d.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan report
DELIMITER //

CREATE PROCEDURE get_loan_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        l.*,
        TIMESTAMPDIFF(DAY, l.request_date, l.approval_date) AS approval_days,
        TIMESTAMPDIFF(DAY, l.approval_date, l.repayment_date) AS repayment_days
    FROM employee_loans l
    WHERE l.employee_id = p_employee_id AND l.request_date BETWEEN p_start_date AND p_end_date
    ORDER BY l.status, l.request_date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi report
DELIMITER //

CREATE PROCEDURE get_kpi_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        k.*,
        TIMESTAMPDIFF(DAY, k.date, NOW()) AS days_ago
    FROM kpi_points k
    WHERE k.employee_id = p_employee_id AND k.date BETWEEN p_start_date AND p_end_date
    ORDER BY k.date DESC, k.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification report
DELIMITER //

CREATE PROCEDURE get_notification_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        n.*,
        TIMESTAMPDIFF(DAY, n.created_at, NOW()) AS days_ago
    FROM notifications n
    WHERE n.employee_id = p_employee_id AND n.created_at BETWEEN p_start_date AND p_end_date
    ORDER BY n.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log report
DELIMITER //

CREATE PROCEDURE get_system_log_report(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        l.*,
        TIMESTAMPDIFF(DAY, l.created_at, NOW()) AS days_ago
    FROM system_logs l
    WHERE (l.employee_id = p_employee_id OR l.employee_id IS NULL) AND l.created_at BETWEEN p_start_date AND p_end_date
    ORDER BY l.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get setting report
DELIMITER //

CREATE PROCEDURE get_setting_report(IN p_key VARCHAR(100))
BEGIN
    SELECT
        s.*
    FROM settings s
    WHERE s.setting_key = p_key;
END//

DELIMITER ;

-- Buat stored procedure untuk get holiday report
DELIMITER //

CREATE PROCEDURE get_holiday_report(IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        h.*
    FROM holidays h
    WHERE h.date BETWEEN p_start_date AND p_end_date
    ORDER BY h.date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get payroll report
DELIMITER //

CREATE PROCEDURE get_payroll_report(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        pr.*
    FROM payroll_reports pr
    WHERE pr.employee_id = p_employee_id AND pr.month = p_month AND pr.year = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get payslip report
DELIMITER //

CREATE PROCEDURE get_payslip_report(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        ps.*
    FROM payslips ps
    WHERE ps.employee_id = p_employee_id AND ps.month = p_month AND ps.year = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get admin dashboard report
DELIMITER //

CREATE PROCEDURE get_admin_dashboard_report()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM employees) AS total_employees,
        (SELECT COUNT(*) FROM tickets WHERE status = 'pending') AS pending_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'in_progress') AS in_progress_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'completed') AS completed_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'failed') AS failed_tickets,
        (SELECT COUNT(*) FROM employee_loans WHERE status = 'pending') AS pending_loans,
        (SELECT COUNT(*) FROM employee_loans WHERE status = 'approved') AS approved_loans,
        (SELECT COUNT(*) FROM employee_loans WHERE status = 'repaid') AS repaid_loans,
        (SELECT COUNT(*) FROM attendance WHERE DATE(check_in) = CURDATE()) AS today_attendance,
        (SELECT COUNT(*) FROM notifications WHERE is_read = 0) AS unread_notifications;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee list
DELIMITER //

CREATE PROCEDURE get_employee_list(IN p_role VARCHAR(20))
BEGIN
    SELECT
        e.*
    FROM employees e
    WHERE p_role IS NULL OR e.role = p_role
    ORDER BY e.name ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket list
DELIMITER //

CREATE PROCEDURE get_ticket_list(IN p_status VARCHAR(20), IN p_employee_id INT)
BEGIN
    SELECT
        t.*,
        e.name AS technician_name
    FROM tickets t
    LEFT JOIN employees e ON t.employee_id = e.id
    WHERE (p_status IS NULL OR t.status = p_status) AND (p_employee_id IS NULL OR t.employee_id = p_employee_id)
    ORDER BY t.assigned_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction list
DELIMITER //

CREATE PROCEDURE get_deduction_list(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        d.*,
        t.ticket_number
    FROM deductions d
    LEFT JOIN tickets t ON d.ticket_id = t.id
    WHERE d.employee_id = p_employee_id AND d.date BETWEEN p_start_date AND p_end_date
    ORDER BY d.date DESC, d.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan list
DELIMITER //

CREATE PROCEDURE get_loan_list(IN p_employee_id INT, IN p_status VARCHAR(20))
BEGIN
    SELECT
        l.*
    FROM employee_loans l
    WHERE l.employee_id = p_employee_id AND (p_status IS NULL OR l.status = p_status)
    ORDER BY l.status, l.request_date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get gps tracking list
DELIMITER //

CREATE PROCEDURE get_gps_tracking_list(IN p_employee_id INT, IN p_start_date DATETIME, IN p_end_date DATETIME)
BEGIN
    SELECT
        g.*
    FROM gps_tracking g
    WHERE g.employee_id = p_employee_id AND g.recorded_at BETWEEN p_start_date AND p_end_date
    ORDER BY g.recorded_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi list
DELIMITER //

CREATE PROCEDURE get_kpi_list(IN p_employee_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        k.*
    FROM kpi_points k
    WHERE k.employee_id = p_employee_id AND k.date BETWEEN p_start_date AND p_end_date
    ORDER BY k.date DESC, k.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification list
DELIMITER //

CREATE PROCEDURE get_notification_list(IN p_employee_id INT, IN p_is_read BOOLEAN)
BEGIN
    SELECT
        n.*
    FROM notifications n
    WHERE n.employee_id = p_employee_id AND (p_is_read IS NULL OR n.is_read = p_is_read)
    ORDER BY n.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log list
DELIMITER //

CREATE PROCEDURE get_system_log_list(IN p_employee_id INT, IN p_start_date DATETIME, IN p_end_date DATETIME)
BEGIN
    SELECT
        l.*
    FROM system_logs l
    WHERE (l.employee_id = p_employee_id OR l.employee_id IS NULL) AND l.created_at BETWEEN p_start_date AND p_end_date
    ORDER BY l.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get setting list
DELIMITER //

CREATE PROCEDURE get_setting_list()
BEGIN
    SELECT
        s.*
    FROM settings s
    ORDER BY s.setting_key ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get holiday list
DELIMITER //

CREATE PROCEDURE get_holiday_list(IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT
        h.*
    FROM holidays h
    WHERE h.date BETWEEN p_start_date AND p_end_date
    ORDER BY h.date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get payroll list
DELIMITER //

CREATE PROCEDURE get_payroll_list(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        pr.*
    FROM payroll_reports pr
    WHERE pr.employee_id = p_employee_id AND pr.month = p_month AND pr.year = p_year
    ORDER BY pr.year DESC, pr.month DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get payslip list
DELIMITER //

CREATE PROCEDURE get_payslip_list(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        ps.*
    FROM payslips ps
    WHERE ps.employee_id = p_employee_id AND ps.month = p_month AND ps.year = p_year
    ORDER BY ps.year DESC, ps.month DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk mark notification as read
DELIMITER //

CREATE PROCEDURE mark_notification_read(IN p_notification_id INT)
BEGIN
    UPDATE notifications SET is_read = 1 WHERE id = p_notification_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'notification_read', CONCAT('Notification read: ID ', p_notification_id));
END//

DELIMITER ;

-- Buat stored procedure untuk delete notification
DELIMITER //

CREATE PROCEDURE delete_notification(IN p_notification_id INT)
BEGIN
    DELETE FROM notifications WHERE id = p_notification_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'notification_deleted', CONCAT('Notification deleted: ID ', p_notification_id));
END//

DELIMITER ;

-- Buat stored procedure untuk delete ticket
DELIMITER //

CREATE PROCEDURE delete_ticket(IN p_ticket_id INT)
BEGIN
    DELETE FROM tickets WHERE id = p_ticket_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'ticket_deleted', CONCAT('Ticket deleted: ID ', p_ticket_id));
END//

DELIMITER ;

-- Buat stored procedure untuk update ticket
DELIMITER //

CREATE PROCEDURE update_ticket(IN p_ticket_id INT, IN p_status VARCHAR(20), IN p_customer_name VARCHAR(100), 
                             IN p_location VARCHAR(255), IN p_description TEXT)
BEGIN
    UPDATE tickets SET 
        status = p_status,
        customer_name = p_customer_name,
        location = p_location,
        description = p_description,
        updated_at = NOW()
    WHERE id = p_ticket_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'ticket_updated', CONCAT('Ticket updated: ID ', p_ticket_id));
END//

DELIMITER ;

-- Buat stored procedure untuk update employee
DELIMITER //

CREATE PROCEDURE update_employee_full(IN p_id INT, IN p_name VARCHAR(100), IN p_email VARCHAR(100), 
                                  IN p_base_salary DECIMAL(10,2), IN p_role VARCHAR(20), IN p_allowances DECIMAL(10,2))
BEGIN
    UPDATE employees SET 
        name = p_name,
        email = p_email,
        base_salary = p_base_salary,
        role = p_role,
        allowances = p_allowances,
        updated_at = NOW()
    WHERE id = p_id;
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'employee_updated', CONCAT('Employee updated: ID ', p_id));
END//

DELIMITER ;

-- Buat stored procedure untuk create employee with password hash
DELIMITER //

CREATE PROCEDURE create_employee_with_password(IN p_name VARCHAR(100), IN p_email VARCHAR(100), 
                                          IN p_password VARCHAR(255), IN p_base_salary DECIMAL(10,2), 
                                          IN p_role VARCHAR(20), IN p_allowances DECIMAL(10,2))
BEGIN
    DECLARE v_hashed_password VARCHAR(255);
    
    -- Hash password
    SET v_hashed_password = SHA2(p_password, 256);
    
    -- Insert employee
    INSERT INTO employees (name, email, password, base_salary, role, allowances)
    VALUES (p_name, p_email, v_hashed_password, p_base_salary, p_role, p_allowances);
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (1, 'employee_created', CONCAT('Employee created: ', p_name));
END//

DELIMITER ;

-- Buat stored procedure untuk change employee password
DELIMITER //

CREATE PROCEDURE change_employee_password(IN p_employee_id INT, IN p_old_password VARCHAR(255), IN p_new_password VARCHAR(255))
BEGIN
    DECLARE v_current_password VARCHAR(255);
    
    -- Ambil password saat ini
    SELECT password INTO v_current_password FROM employees WHERE id = p_employee_id;
    
    -- Verifikasi password lama
    IF SHA2(p_old_password, 256) = v_current_password THEN
        -- Update password baru
        UPDATE employees SET password = SHA2(p_new_password, 256), updated_at = NOW() WHERE id = p_employee_id;
        
        -- Insert log
        INSERT INTO system_logs (employee_id, action, details)
        VALUES (p_employee_id, 'password_changed', 'Password changed successfully');
        
        -- Kirim notifikasi
        INSERT INTO notifications (employee_id, type, message, data)
        VALUES (p_employee_id, 'password_changed', 'Password Anda telah diubah', 
                JSON_OBJECT('changed_at', NOW()));
    ELSE
        -- Insert log untuk kegagalan
        INSERT INTO system_logs (employee_id, action, details)
        VALUES (p_employee_id, 'password_change_failed', 'Password change failed: wrong old password');
        
        -- Kirim notifikasi kegagalan
        INSERT INTO notifications (employee_id, type, message, data)
        VALUES (p_employee_id, 'password_change_failed', 'Gagal mengubah password: password lama salah', 
                JSON_OBJECT('attempted_at', NOW()));
    END IF;
END//

DELIMITER ;

-- Buat stored procedure untuk request loan
DELIMITER //

CREATE PROCEDURE request_loan(IN p_employee_id INT, IN p_amount DECIMAL(10,2), IN p_reason TEXT)
BEGIN
    INSERT INTO employee_loans (employee_id, amount, request_date, status)
    VALUES (p_employee_id, p_amount, CURDATE(), 'pending');
    
    -- Insert log
    INSERT INTO system_logs (employee_id, action, details)
    VALUES (p_employee_id, 'loan_requested', CONCAT('Loan requested: Rp ', p_amount, ' for ', p_reason));
    
    -- Kirim notifikasi
    INSERT INTO notifications (employee_id, type, message, data)
    VALUES (p_employee_id, 'loan_requested', 'Permintaan pinjaman telah diajukan', 
            JSON_OBJECT('amount', p_amount, 'reason', p_reason, 'request_date', CURDATE()));
END//

DELIMITER ;

-- Buat stored procedure untuk get loan details
DELIMITER //

CREATE PROCEDURE get_loan_details(IN p_loan_id INT)
BEGIN
    SELECT
        l.*,
        TIMESTAMPDIFF(DAY, l.request_date, l.approval_date) AS approval_days,
        TIMESTAMPDIFF(DAY, l.approval_date, l.repayment_date) AS repayment_days
    FROM employee_loans l
    WHERE l.id = p_loan_id;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket count by status
DELIMITER //

CREATE PROCEDURE get_ticket_count_by_status(IN p_employee_id INT)
BEGIN
    SELECT
        status,
        COUNT(*) AS ticket_count
    FROM tickets
    WHERE employee_id = p_employee_id
    GROUP BY status;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance count by status
DELIMITER //

CREATE PROCEDURE get_attendance_count_by_status(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        status,
        COUNT(*) AS attendance_count
    FROM attendance
    WHERE employee_id = p_employee_id AND MONTH(check_in) = p_month AND YEAR(check_in) = p_year
    GROUP BY status;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction count by type
DELIMITER //

CREATE PROCEDURE get_deduction_count_by_type(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        type,
        COUNT(*) AS deduction_count,
        SUM(amount) AS total_amount
    FROM deductions
    WHERE employee_id = p_employee_id AND MONTH(date) = p_month AND YEAR(date) = p_year
    GROUP BY type;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi count by reason
DELIMITER //

CREATE PROCEDURE get_kpi_count_by_reason(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        reason,
        COUNT(*) AS kpi_count,
        SUM(points) AS total_points
    FROM kpi_points
    WHERE employee_id = p_employee_id AND MONTH(date) = p_month AND YEAR(date) = p_year
    GROUP BY reason;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification count by type
DELIMITER //

CREATE PROCEDURE get_notification_count_by_type(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        type,
        COUNT(*) AS notification_count
    FROM notifications
    WHERE employee_id = p_employee_id AND MONTH(created_at) = p_month AND YEAR(created_at) = p_year
    GROUP BY type;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log count by action
DELIMITER //

CREATE PROCEDURE get_system_log_count_by_action(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        action,
        COUNT(*) AS log_count
    FROM system_logs
    WHERE (employee_id = p_employee_id OR employee_id IS NULL) AND MONTH(created_at) = p_month AND YEAR(created_at) = p_year
    GROUP BY action;
END//

DELIMITER ;

-- Buat stored procedure untuk get holiday count by month
DELIMITER //

CREATE PROCEDURE get_holiday_count_by_month(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        COUNT(*) AS holiday_count
    FROM holidays
    WHERE MONTH(date) = p_month AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get payroll count by employee
DELIMITER //

CREATE PROCEDURE get_payroll_count_by_employee(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        employee_id,
        COUNT(*) AS payroll_count
    FROM payroll_reports
    WHERE month = p_month AND year = p_year
    GROUP BY employee_id;
END//

DELIMITER ;

-- Buat stored procedure untuk get payslip count by employee
DELIMITER //

CREATE PROCEDURE get_payslip_count_by_employee(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        employee_id,
        COUNT(*) AS payslip_count
    FROM payslips
    WHERE month = p_month AND year = p_year
    GROUP BY employee_id;
END//

DELIMITER ;

-- Buat stored procedure untuk export data to CSV
DELIMITER //

CREATE PROCEDURE export_to_csv(IN p_table_name VARCHAR(50), IN p_file_path VARCHAR(255))
BEGIN
    SET @sql = CONCAT('SELECT * INTO OUTFILE "', p_file_path, '" 
                     FIELDS TERMINATED BY "," 
                     ENCLOSED BY "\'" 
                     LINES TERMINATED BY "\n" 
                     FROM ', p_table_name);
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;

-- Buat stored procedure untuk
-- Lanjutan Skrip SQL untuk Sistem Manajemen Karyawan & Layanan Lapangan

-- Buat stored procedure untuk import data from CSV
DELIMITER //

CREATE PROCEDURE import_from_csv(IN p_table_name VARCHAR(50), IN p_file_path VARCHAR(255))
BEGIN
    SET @sql = CONCAT('LOAD DATA INFILE "', p_file_path, '" 
                     INTO TABLE ', p_table_name, ' 
                     FIELDS TERMINATED BY "," 
                     ENCLOSED BY "\'" 
                     LINES TERMINATED BY "\n"');
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;

-- Buat stored procedure untuk backup database
DELIMITER //

CREATE PROCEDURE backup_database(IN p_backup_path VARCHAR(255))
BEGIN
    SET @sql = CONCAT('BACKUP DATABASE employee_management TO DISK "', p_backup_path, '"');
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;

-- Buat stored procedure untuk restore database
DELIMITER //

CREATE PROCEDURE restore_database(IN p_backup_path VARCHAR(255))
BEGIN
    SET @sql = CONCAT('RESTORE DATABASE employee_management FROM DISK "', p_backup_path, '"');
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee performance report
DELIMITER //

CREATE PROCEDURE get_employee_performance_report(IN p_employee_id INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        e.role AS employee_role,
        COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) AS completed_tickets,
        COUNT(DISTINCT CASE WHEN t.status = 'failed' THEN t.id END) AS failed_tickets,
        SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) AS late_deductions,
        SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) AS ticket_deductions,
        SUM(k.points) AS total_kpi_points,
        AVG(TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at)) AS avg_completion_time,
        (e.base_salary + e.allowances) - 
        (SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END)) AS net_salary
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND t.status IN ('completed', 'failed') AND MONTH(t.assigned_at) = p_month AND YEAR(t.assigned_at) = p_year
    LEFT JOIN deductions d ON e.id = d.employee_id AND MONTH(d.date) = p_month AND YEAR(d.date) = p_year
    LEFT JOIN kpi_points k ON e.id = k.employee_id AND MONTH(k.date) = p_month AND YEAR(k.date) = p_year
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, e.role, e.base_salary, e.allowances;
END//

DELIMITER ;

-- Buat stored procedure untuk get company overview
DELIMITER //

CREATE PROCEDURE get_company_overview(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM employees) AS total_employees,
        (SELECT COUNT(*) FROM employees WHERE role = 'technician') AS total_technicians,
        (SELECT COUNT(*) FROM employees WHERE role = 'admin') AS total_admins,
        (SELECT COUNT(*) FROM employees WHERE role = 'hr') AS total_hr,
        (SELECT COUNT(*) FROM tickets WHERE status = 'pending' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS pending_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'in_progress' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS in_progress_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'completed' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS completed_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'failed' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS failed_tickets,
        (SELECT SUM(base_salary) FROM employees) AS total_base_salary,
        (SELECT SUM(allowances) FROM employees) AS total_allowances,
        (SELECT SUM(amount) FROM deductions WHERE MONTH(date) = p_month AND YEAR(date) = p_year) AS total_deductions,
        (SELECT SUM(amount) FROM employee_loans WHERE status = 'approved' AND MONTH(approval_date) = p_month AND YEAR(approval_date) = p_year) AS total_loans_approved,
        (SELECT COUNT(*) FROM holidays WHERE MONTH(date) = p_month AND YEAR(date) = p_year) AS total_holidays
    FROM dual;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance summary
DELIMITER //

CREATE PROCEDURE get_attendance_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        COUNT(a.id) AS total_days,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS present_days,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_days,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) AS absent_days,
        AVG(TIMESTAMPDIFF(HOUR, a.check_in, a.check_out)) AS avg_work_hours,
        SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END) * 2 AS estimated_late_deductions
    FROM employees e
    LEFT JOIN attendance a ON e.id = a.employee_id AND MONTH(a.check_in) = p_month AND YEAR(a.check_in) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket performance report
DELIMITER //

CREATE PROCEDURE get_ticket_performance_report(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS technician_name,
        COUNT(t.id) AS total_tickets_assigned,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS tickets_completed,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) AS tickets_failed,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) / COUNT(t.id) * 100 AS completion_rate,
        AVG(TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at)) AS avg_completion_time,
        SUM(CASE WHEN t.status = 'failed' THEN 1 ELSE 0 END) * (SELECT value FROM settings WHERE setting_key = 'ticket_deduction') / 100 * (SELECT value FROM settings WHERE setting_key = 'default_base_salary') / (SELECT value FROM settings WHERE setting_key = 'working_days') AS estimated_deductions
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND MONTH(t.assigned_at) = p_month AND YEAR(t.assigned_at) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name;
END//

DELIMITER ;

-- Buat stored procedure untuk get payroll summary
DELIMITER //

CREATE PROCEDURE get_payroll_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        e.base_salary,
        e.allowances,
        (SELECT SUM(amount) FROM deductions WHERE employee_id = e.id AND MONTH(date) = p_month AND YEAR(date) = p_year) AS total_deductions,
        (e.base_salary + e.allowances) - (SELECT SUM(amount) FROM deductions WHERE employee_id = e.id AND MONTH(date) = p_month AND YEAR(date) = p_year) AS net_salary,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = e.id AND status = 'completed' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS tickets_completed,
        (SELECT SUM(points) FROM kpi_points WHERE employee_id = e.id AND MONTH(date) = p_month AND YEAR(date) = p_year) AS kpi_points
    FROM employees e
    WHERE e.role = 'technician'
    ORDER BY e.name ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan summary
DELIMITER //

CREATE PROCEDURE get_loan_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        COUNT(l.id) AS total_loans,
        COUNT(CASE WHEN l.status = 'pending' THEN 1 END) AS pending_loans,
        COUNT(CASE WHEN l.status = 'approved' THEN 1 END) AS approved_loans,
        COUNT(CASE WHEN l.status = 'repaid' THEN 1 END) AS repaid_loans,
        SUM(l.amount) AS total_loan_amount,
        SUM(CASE WHEN l.status = 'approved' THEN l.amount ELSE 0 END) AS approved_loan_amount,
        SUM(CASE WHEN l.status = 'repaid' THEN l.amount ELSE 0 END) AS repaid_loan_amount
    FROM employees e
    LEFT JOIN employee_loans l ON e.id = l.employee_id AND MONTH(l.request_date) = p_month AND YEAR(l.request_date) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi summary
DELIMITER //

CREATE PROCEDURE get_kpi_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        COUNT(k.id) AS total_kpi_entries,
        SUM(k.points) AS total_kpi_points,
        AVG(k.points) AS avg_kpi_points_per_entry,
        (SELECT value FROM settings WHERE setting_key = 'default_base_salary') / (SELECT value FROM settings WHERE setting_key = 'working_days') * SUM(k.points) / 100 AS estimated_bonus
    FROM employees e
    LEFT JOIN kpi_points k ON e.id = k.employee_id AND MONTH(k.date) = p_month AND YEAR(k.date) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification summary
DELIMITER //

CREATE PROCEDURE get_notification_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        COUNT(n.id) AS total_notifications,
        COUNT(CASE WHEN n.is_read = 0 THEN 1 END) AS unread_notifications,
        COUNT(CASE WHEN n.type = 'new_ticket' THEN 1 END) AS new_ticket_notifications,
        COUNT(CASE WHEN n.type = 'checkin_reminder' THEN 1 END) AS checkin_reminder_notifications,
        COUNT(CASE WHEN n.type = 'payroll_announcement' THEN 1 END) AS payroll_announcement_notifications,
        COUNT(CASE WHEN n.type = 'loan_approved' THEN 1 END) AS loan_approved_notifications,
        COUNT(CASE WHEN n.type = 'loan_repaid' THEN 1 END) AS loan_repaid_notifications,
        COUNT(CASE WHEN n.type = 'kpi_added' THEN 1 END) AS kpi_added_notifications
    FROM employees e
    LEFT JOIN notifications n ON e.id = n.employee_id AND MONTH(n.created_at) = p_month AND YEAR(n.created_at) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log summary
DELIMITER //

CREATE PROCEDURE get_system_log_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        COUNT(l.id) AS total_logs,
        COUNT(CASE WHEN l.action LIKE 'user_login' THEN 1 END) AS login_logs,
        COUNT(CASE WHEN l.action LIKE 'ticket_%' THEN 1 END) AS ticket_logs,
        COUNT(CASE WHEN l.action LIKE 'loan_%' THEN 1 END) AS loan_logs,
        COUNT(CASE WHEN l.action LIKE 'setting_%' THEN 1 END) AS setting_logs,
        COUNT(CASE WHEN l.action LIKE 'holiday_%' THEN 1 END) AS holiday_logs,
        COUNT(CASE WHEN l.action LIKE 'notification_%' THEN 1 END) AS notification_logs
    FROM employees e
    LEFT JOIN system_logs l ON e.id = l.employee_id AND MONTH(l.created_at) = p_month AND YEAR(l.created_at) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name;
END//

DELIMITER ;

-- Buat stored procedure untuk get setting summary
DELIMITER //

CREATE PROCEDURE get_setting_summary()
BEGIN
    SELECT
        setting_key,
        value,
        created_at,
        updated_at
    FROM settings
    ORDER BY setting_key ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get holiday summary
DELIMITER //

CREATE PROCEDURE get_holiday_summary(IN p_year INT)
BEGIN
    SELECT
        MONTH(date) AS month,
        COUNT(*) AS holiday_count,
        GROUP_CONCAT(name) AS holiday_names
    FROM holidays
    WHERE YEAR(date) = p_year
    GROUP BY MONTH(date)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get payroll report summary
DELIMITER //

CREATE PROCEDURE get_payroll_report_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        pr.base_salary,
        pr.allowances,
        pr.total_deductions,
        pr.net_salary,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = e.id AND status = 'completed' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS tickets_completed,
        (SELECT SUM(points) FROM kpi_points WHERE employee_id = e.id AND MONTH(date) = p_month AND YEAR(date) = p_year) AS kpi_points
    FROM payroll_reports pr
    JOIN employees e ON pr.employee_id = e.id
    WHERE pr.month = p_month AND pr.year = p_year
    ORDER BY e.name ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get payslip report summary
DELIMITER //

CREATE PROCEDURE get_payslip_report_summary(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        ps.base_salary,
        ps.allowances,
        ps.total_deductions,
        ps.net_salary,
        ps.generated_at
    FROM payslips ps
    JOIN employees e ON ps.employee_id = e.id
    WHERE ps.month = p_month AND ps.year = p_year
    ORDER BY e.name ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee attendance trend
DELIMITER //

CREATE PROCEDURE get_employee_attendance_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(a.check_in, '%Y-%m') AS month,
        COUNT(a.id) AS total_days,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS present_days,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_days,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) AS absent_days
    FROM attendance a
    WHERE a.employee_id = p_employee_id 
    AND a.check_in >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(a.check_in, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee ticket trend
DELIMITER //

CREATE PROCEDURE get_employee_ticket_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(t.assigned_at, '%Y-%m') AS month,
        COUNT(t.id) AS total_tickets,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_tickets,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) AS failed_tickets,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) / COUNT(t.id) * 100 AS completion_rate
    FROM tickets t
    WHERE t.employee_id = p_employee_id 
    AND t.assigned_at >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(t.assigned_at, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee deduction trend
DELIMITER //

CREATE PROCEDURE get_employee_deduction_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(d.date, '%Y-%m') AS month,
        COUNT(d.id) AS total_deductions,
        SUM(d.amount) AS total_amount,
        AVG(d.amount) AS avg_amount
    FROM deductions d
    WHERE d.employee_id = p_employee_id 
    AND d.date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(d.date, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee loan trend
DELIMITER //

CREATE PROCEDURE get_employee_loan_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(l.request_date, '%Y-%m') AS month,
        COUNT(l.id) AS total_loans,
        COUNT(CASE WHEN l.status = 'pending' THEN 1 END) AS pending_loans,
        COUNT(CASE WHEN l.status = 'approved' THEN 1 END) AS approved_loans,
        COUNT(CASE WHEN l.status = 'repaid' THEN 1 END) AS repaid_loans,
        SUM(l.amount) AS total_amount
    FROM employee_loans l
    WHERE l.employee_id = p_employee_id 
    AND l.request_date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(l.request_date, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee kpi trend
DELIMITER //

CREATE PROCEDURE get_employee_kpi_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(k.date, '%Y-%m') AS month,
        COUNT(k.id) AS total_kpi_entries,
        SUM(k.points) AS total_points,
        AVG(k.points) AS avg_points
    FROM kpi_points k
    WHERE k.employee_id = p_employee_id 
    AND k.date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(k.date, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee notification trend
DELIMITER //

CREATE PROCEDURE get_employee_notification_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(n.created_at, '%Y-%m') AS month,
        COUNT(n.id) AS total_notifications,
        COUNT(CASE WHEN n.is_read = 0 THEN 1 END) AS unread_notifications
    FROM notifications n
    WHERE n.employee_id = p_employee_id 
    AND n.created_at >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(n.created_at, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee system log trend
DELIMITER //

CREATE PROCEDURE get_employee_system_log_trend(IN p_employee_id INT, IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(l.created_at, '%Y-%m') AS month,
        COUNT(l.id) AS total_logs
    FROM system_logs l
    WHERE l.employee_id = p_employee_id 
    AND l.created_at >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(l.created_at, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company attendance trend
DELIMITER //

CREATE PROCEDURE get_company_attendance_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(a.check_in, '%Y-%m') AS month,
        COUNT(a.id) AS total_attendances,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS present_attendances,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_attendances,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) AS absent_attendances,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) / COUNT

-- Lanjutan Skrip SQL untuk Sistem Manajemen Karyawan & Layanan Lapangan

-- Buat stored procedure untuk get company attendance trend
DELIMITER //

CREATE PROCEDURE get_company_attendance_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(a.check_in, '%Y-%m') AS month,
        COUNT(a.id) AS total_attendances,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS present_attendances,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_attendances,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) AS absent_attendances,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) / COUNT(a.id) * 100 AS attendance_rate,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) / COUNT(a.id) * 100 AS late_rate
    FROM attendance a
    WHERE a.check_in >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(a.check_in, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company ticket trend
DELIMITER //

CREATE PROCEDURE get_company_ticket_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(t.assigned_at, '%Y-%m') AS month,
        COUNT(t.id) AS total_tickets,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_tickets,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) AS failed_tickets,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) / COUNT(t.id) * 100 AS completion_rate,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) / COUNT(t.id) * 100 AS failure_rate
    FROM tickets t
    WHERE t.assigned_at >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(t.assigned_at, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company deduction trend
DELIMITER //

CREATE PROCEDURE get_company_deduction_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(d.date, '%Y-%m') AS month,
        COUNT(d.id) AS total_deductions,
        SUM(d.amount) AS total_amount,
        AVG(d.amount) AS avg_amount,
        SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) AS late_deductions,
        SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) AS ticket_deductions,
        SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END) AS loan_deductions
    FROM deductions d
    WHERE d.date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(d.date, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company loan trend
DELIMITER //

CREATE PROCEDURE get_company_loan_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(l.request_date, '%Y-%m') AS month,
        COUNT(l.id) AS total_loans,
        COUNT(CASE WHEN l.status = 'pending' THEN 1 END) AS pending_loans,
        COUNT(CASE WHEN l.status = 'approved' THEN 1 END) AS approved_loans,
        COUNT(CASE WHEN l.status = 'repaid' THEN 1 END) AS repaid_loans,
        SUM(l.amount) AS total_amount,
        SUM(CASE WHEN l.status = 'approved' THEN l.amount ELSE 0 END) AS approved_amount,
        SUM(CASE WHEN l.status = 'repaid' THEN l.amount ELSE 0 END) AS repaid_amount
    FROM employee_loans l
    WHERE l.request_date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(l.request_date, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company kpi trend
DELIMITER //

CREATE PROCEDURE get_company_kpi_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(k.date, '%Y-%m') AS month,
        COUNT(k.id) AS total_kpi_entries,
        SUM(k.points) AS total_points,
        AVG(k.points) AS avg_points
    FROM kpi_points k
    WHERE k.date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(k.date, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company notification trend
DELIMITER //

CREATE PROCEDURE get_company_notification_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(n.created_at, '%Y-%m') AS month,
        COUNT(n.id) AS total_notifications,
        COUNT(CASE WHEN n.is_read = 0 THEN 1 END) AS unread_notifications,
        COUNT(CASE WHEN n.type = 'new_ticket' THEN 1 END) AS new_ticket_notifications,
        COUNT(CASE WHEN n.type = 'checkin_reminder' THEN 1 END) AS checkin_reminder_notifications,
        COUNT(CASE WHEN n.type = 'payroll_announcement' THEN 1 END) AS payroll_announcement_notifications
    FROM notifications n
    WHERE n.created_at >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(n.created_at, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company system log trend
DELIMITER //

CREATE PROCEDURE get_company_system_log_trend(IN p_months INT)
BEGIN
    SELECT
        DATE_FORMAT(l.created_at, '%Y-%m') AS month,
        COUNT(l.id) AS total_logs,
        COUNT(CASE WHEN l.action LIKE 'user_login' THEN 1 END) AS login_logs,
        COUNT(CASE WHEN l.action LIKE 'ticket_%' THEN 1 END) AS ticket_logs,
        COUNT(CASE WHEN l.action LIKE 'loan_%' THEN 1 END) AS loan_logs,
        COUNT(CASE WHEN l.action LIKE 'setting_%' THEN 1 END) AS setting_logs
    FROM system_logs l
    WHERE l.created_at >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY DATE_FORMAT(l.created_at, '%Y-%m')
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get company performance report
DELIMITER //

CREATE PROCEDURE get_company_performance_report(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM employees) AS total_employees,
        (SELECT COUNT(*) FROM employees WHERE role = 'technician') AS total_technicians,
        (SELECT COUNT(*) FROM tickets WHERE status = 'completed' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS completed_tickets,
        (SELECT COUNT(*) FROM tickets WHERE status = 'failed' AND MONTH(assigned_at) = p_month AND YEAR(assigned_at) = p_year) AS failed_tickets,
        (SELECT SUM(amount) FROM deductions WHERE MONTH(date) = p_month AND YEAR(date) = p_year) AS total_deductions,
        (SELECT SUM(amount) FROM employee_loans WHERE status = 'approved' AND MONTH(approval_date) = p_month AND YEAR(approval_date) = p_year) AS total_loans_approved,
        (SELECT SUM(points) FROM kpi_points WHERE MONTH(date) = p_month AND YEAR(date) = p_year) AS total_kpi_points,
        (SELECT COUNT(*) FROM attendance WHERE MONTH(check_in) = p_month AND YEAR(check_in) = p_year) AS total_attendances,
        (SELECT COUNT(*) FROM notifications WHERE MONTH(created_at) = p_month AND YEAR(created_at) = p_year) AS total_notifications
    FROM dual;
END//

DELIMITER ;

-- Buat stored procedure untuk get employee ranking
DELIMITER //

CREATE PROCEDURE get_employee_ranking(IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        e.role AS employee_role,
        COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) AS completed_tickets,
        SUM(k.points) AS total_kpi_points,
        (e.base_salary + e.allowances) - 
        (SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END)) AS net_salary,
        RANK() OVER (ORDER BY COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) DESC, 
                    SUM(k.points) DESC) AS performance_rank
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND t.status = 'completed' AND MONTH(t.assigned_at) = p_month AND YEAR(t.assigned_at) = p_year
    LEFT JOIN deductions d ON e.id = d.employee_id AND MONTH(d.date) = p_month AND YEAR(d.date) = p_year
    LEFT JOIN kpi_points k ON e.id = k.employee_id AND MONTH(k.date) = p_month AND YEAR(k.date) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name, e.role, e.base_salary, e.allowances
    ORDER BY performance_rank ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get top performers
DELIMITER //

CREATE PROCEDURE get_top_performers(IN p_limit INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        e.role AS employee_role,
        COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) AS completed_tickets,
        SUM(k.points) AS total_kpi_points,
        (e.base_salary + e.allowances) - 
        (SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END)) AS net_salary
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND t.status = 'completed' AND MONTH(t.assigned_at) = p_month AND YEAR(t.assigned_at) = p_year
    LEFT JOIN deductions d ON e.id = d.employee_id AND MONTH(d.date) = p_month AND YEAR(d.date) = p_year
    LEFT JOIN kpi_points k ON e.id = k.employee_id AND MONTH(k.date) = p_month AND YEAR(k.date) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name, e.role, e.base_salary, e.allowances
    ORDER BY completed_tickets DESC, total_kpi_points DESC
    LIMIT p_limit;
END//

DELIMITER ;

-- Buat stored procedure untuk get bottom performers
DELIMITER //

CREATE PROCEDURE get_bottom_performers(IN p_limit INT, IN p_month INT, IN p_year INT)
BEGIN
    SELECT
        e.name AS employee_name,
        e.role AS employee_role,
        COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) AS completed_tickets,
        SUM(k.points) AS total_kpi_points,
        (e.base_salary + e.allowances) - 
        (SUM(CASE WHEN d.type = 'late' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'ticket' THEN d.amount ELSE 0 END) + 
         SUM(CASE WHEN d.type = 'loan' THEN d.amount ELSE 0 END)) AS net_salary
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND t.status = 'completed' AND MONTH(t.assigned_at) = p_month AND YEAR(t.assigned_at) = p_year
    LEFT JOIN deductions d ON e.id = d.employee_id AND MONTH(d.date) = p_month AND YEAR(d.date) = p_year
    LEFT JOIN kpi_points k ON e.id = k.employee_id AND MONTH(k.date) = p_month AND YEAR(k.date) = p_year
    WHERE e.role = 'technician'
    GROUP BY e.id, e.name, e.role, e.base_salary, e.allowances
    ORDER BY completed_tickets ASC, total_kpi_points ASC
    LIMIT p_limit;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance heatmap
DELIMITER //

CREATE PROCEDURE get_attendance_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        DAYOFWEEK(a.check_in) AS day_of_week,
        WEEK(a.check_in) AS week_of_year,
        COUNT(a.id) AS attendance_count,
        AVG(TIMESTAMPDIFF(HOUR, a.check_in, a.check_out)) AS avg_work_hours
    FROM attendance a
    WHERE a.employee_id = p_employee_id AND YEAR(a.check_in) = p_year
    GROUP BY day_of_week, week_of_year
    ORDER BY week_of_year, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket heatmap
DELIMITER //

CREATE PROCEDURE get_ticket_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        DAYOFWEEK(t.assigned_at) AS day_of_week,
        WEEK(t.assigned_at) AS week_of_year,
        COUNT(t.id) AS ticket_count,
        AVG(TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at)) AS avg_completion_time
    FROM tickets t
    WHERE t.employee_id = p_employee_id AND YEAR(t.assigned_at) = p_year AND t.status = 'completed'
    GROUP BY day_of_week, week_of_year
    ORDER BY week_of_year, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction heatmap
DELIMITER //

CREATE PROCEDURE get_deduction_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(d.date) AS month,
        DAYOFWEEK(d.date) AS day_of_week,
        COUNT(d.id) AS deduction_count,
        SUM(d.amount) AS total_amount
    FROM deductions d
    WHERE d.employee_id = p_employee_id AND YEAR(d.date) = p_year
    GROUP BY month, day_of_week
    ORDER BY month, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan heatmap
DELIMITER //

CREATE PROCEDURE get_loan_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(l.request_date) AS month,
        DAYOFWEEK(l.request_date) AS day_of_week,
        COUNT(l.id) AS loan_count,
        SUM(l.amount) AS total_amount
    FROM employee_loans l
    WHERE l.employee_id = p_employee_id AND YEAR(l.request_date) = p_year
    GROUP BY month, day_of_week
    ORDER BY month, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi heatmap
DELIMITER //

CREATE PROCEDURE get_kpi_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(k.date) AS month,
        DAYOFWEEK(k.date) AS day_of_week,
        COUNT(k.id) AS kpi_count,
        SUM(k.points) AS total_points
    FROM kpi_points k
    WHERE k.employee_id = p_employee_id AND YEAR(k.date) = p_year
    GROUP BY month, day_of_week
    ORDER BY month, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification heatmap
DELIMITER //

CREATE PROCEDURE get_notification_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(n.created_at) AS month,
        DAYOFWEEK(n.created_at) AS day_of_week,
        COUNT(n.id) AS notification_count,
        COUNT(CASE WHEN n.is_read = 0 THEN 1 END) AS unread_count
    FROM notifications n
    WHERE n.employee_id = p_employee_id AND YEAR(n.created_at) = p_year
    GROUP BY month, day_of_week
    ORDER BY month, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log heatmap
DELIMITER //

CREATE PROCEDURE get_system_log_heatmap(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(l.created_at) AS month,
        DAYOFWEEK(l.created_at) AS day_of_week,
        COUNT(l.id) AS log_count
    FROM system_logs l
    WHERE (l.employee_id = p_employee_id OR l.employee_id IS NULL) AND YEAR(l.created_at) = p_year
    GROUP BY month, day_of_week
    ORDER BY month, day_of_week;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance distribution
DELIMITER //

CREATE PROCEDURE get_attendance_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        status,
        COUNT(*) AS count,
        COUNT(*) / (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND YEAR(check_in) = p_year) * 100 AS percentage
    FROM attendance
    WHERE employee_id = p_employee_id AND YEAR(check_in) = p_year
    GROUP BY status;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket distribution
DELIMITER //

CREATE PROCEDURE get_ticket_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        status,
        COUNT(*) AS count,
        COUNT(*) / (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND YEAR(assigned_at) = p_year) * 100 AS percentage
    FROM tickets
    WHERE employee_id = p_employee_id AND YEAR(assigned_at) = p_year
    GROUP BY status;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction distribution
DELIMITER //

CREATE PROCEDURE get_deduction_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        type,
        COUNT(*) AS count,
        SUM(amount) AS total_amount,
        SUM(amount) / (SELECT SUM(amount) FROM deductions WHERE employee_id = p_employee_id AND YEAR(date) = p_year) * 100 AS percentage
    FROM deductions
    WHERE employee_id = p_employee_id AND YEAR(date) = p_year
    GROUP BY type;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan distribution
DELIMITER //

CREATE PROCEDURE get_loan_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        status,
        COUNT(*) AS count,
        SUM(amount) AS total_amount,
        SUM(amount) / (SELECT SUM(amount) FROM employee_loans WHERE employee_id = p_employee_id AND YEAR(request_date) = p_year) * 100 AS percentage
    FROM employee_loans
    WHERE employee_id = p_employee_id AND YEAR(request_date) = p_year
    GROUP BY status;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi distribution
DELIMITER //

CREATE PROCEDURE get_kpi_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        reason,
        COUNT(*) AS count,
        SUM(points) AS total_points,
        SUM(points) / (SELECT SUM(points) FROM kpi_points WHERE employee_id = p_employee_id AND YEAR(date) = p_year) * 100 AS percentage
    FROM kpi_points
    WHERE employee_id = p_employee_id AND YEAR(date) = p_year
    GROUP BY reason;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification distribution
DELIMITER //

CREATE PROCEDURE get_notification_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        type,
        COUNT(*) AS count,
        COUNT(*) / (SELECT COUNT(*) FROM notifications WHERE employee_id = p_employee_id AND YEAR(created_at) = p_year) * 100 AS percentage
    FROM notifications
    WHERE employee_id = p_employee_id AND YEAR(created_at) = p_year
    GROUP BY type;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log distribution
DELIMITER //

CREATE PROCEDURE get_system_log_distribution(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        action,
        COUNT(*) AS count,
        COUNT(*) / (SELECT COUNT(*) FROM system_logs WHERE (employee_id = p_employee_id OR employee_id IS NULL) AND YEAR(created_at) = p_year) * 100 AS percentage
    FROM system_logs
    WHERE (employee_id = p_employee_id OR employee_id IS NULL) AND YEAR(created_at) = p_year
    GROUP BY action;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance summary by month
DELIMITER //

CREATE PROCEDURE get_attendance_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(a.check_in) AS month,
        COUNT(a.id) AS total_days,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS present_days,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_days,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) AS absent_days,
        AVG(TIMESTAMPDIFF(HOUR, a.check_in, a.check_out)) AS avg_work_hours,
        SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END) * 2 AS estimated_late_deductions
    FROM attendance a
    WHERE a.employee_id = p_employee_id AND YEAR(a.check_in) = p_year
    GROUP BY MONTH(a.check_in)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket summary by month
DELIMITER //

CREATE PROCEDURE get_ticket_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(t.assigned_at) AS month,
        COUNT(t.id) AS total_tickets,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_tickets,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) AS failed_tickets,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) / COUNT(t.id) * 100 AS completion_rate,
        AVG(TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at)) AS avg_completion_time,
        SUM(CASE WHEN t.status = 'failed' THEN 1 ELSE 0 END) * (SELECT value FROM settings WHERE setting_key = 'ticket_deduction') / 100 * (SELECT value FROM settings WHERE setting_key = 'default_base_salary') / (SELECT value FROM settings WHERE setting_key = 'working_days') AS estimated_deductions
    FROM tickets t
    WHERE t.employee_id = p_employee_id AND YEAR(t.assigned_at) = p_year
    GROUP BY MONTH(t.assigned_at)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction summary by month
DELIMITER //

CREATE PROCEDURE get_deduction_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(d.date) AS month,
        COUNT(d.id) AS total_deductions,
        SUM(d.amount) AS total_amount,
        AVG(d.amount) AS avg_amount
    FROM deductions d
    WHERE d.employee_id = p_employee_id AND YEAR(d.date) = p_year
    GROUP BY MONTH(d.date)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan summary by month
DELIMITER //

CREATE PROCEDURE get_loan_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(l.request_date) AS month,
        COUNT(l.id) AS total_loans,
        COUNT(CASE WHEN l.status = 'pending' THEN 1 END) AS pending_loans,
        COUNT(CASE WHEN l.status = 'approved' THEN 1 END) AS approved_loans,
        COUNT(CASE WHEN l.status = 'repaid' THEN 1 END) AS repaid_loans,
        SUM(l.amount) AS total_amount
    FROM employee_loans l
    WHERE l.employee_id = p_employee_id AND YEAR(l.request_date) = p_year
    GROUP BY MONTH(l.request_date)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi summary by month
DELIMITER //

CREATE PROCEDURE get_kpi_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(k.date) AS month,
        COUNT(k.id) AS total_kpi_entries,
        SUM(k.points) AS total_points,
        AVG(k.points) AS avg_points
    FROM kpi_points k
    WHERE k.employee_id = p_employee_id AND YEAR(k.date) = p_year
    GROUP BY MONTH(k.date)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification summary by month
DELIMITER //

CREATE PROCEDURE get_notification_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(n.created_at) AS month,
        COUNT(n.id) AS total_notifications,
        COUNT(CASE WHEN n.is_read = 0 THEN 1 END) AS unread_notifications
    FROM notifications n
    WHERE n.employee_id = p_employee_id AND YEAR(n.created_at) = p_year
    GROUP BY MONTH(n.created_at)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log summary by month
DELIMITER //

CREATE PROCEDURE get_system_log_summary_by_month(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        MONTH(l.created_at) AS month,
        COUNT(l.id) AS total_logs
    FROM system_logs l
    WHERE (l.employee_id = p_employee_id OR l.employee_id IS NULL) AND YEAR(l.created_at) = p_year
    GROUP BY MONTH(l.created_at)
    ORDER BY month ASC;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance comparison
DELIMITER //

CREATE PROCEDURE get_attendance_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(a.check_in) AS month,
        COUNT(a.id) AS attendance_count,
        AVG(TIMESTAMPDIFF(HOUR, a.check_in, a.check_out)) AS avg_work_hours,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_count
    FROM employees e
    LEFT JOIN attendance a ON e.id = a.employee_id AND YEAR(a.check_in) = p_year AND MONTH(a.check_in) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(a.check_in);
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket comparison
DELIMITER //

CREATE PROCEDURE get_ticket_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(t.assigned_at) AS month,
        COUNT(t.id) AS ticket_count,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_count,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) AS failed_count
    FROM employees e
    LEFT JOIN tickets t ON e.id = t.employee_id AND YEAR(t.assigned_at) = p_year AND MONTH(t.assigned_at) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(t.assigned_at);
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction comparison
DELIMITER //

CREATE PROCEDURE get_deduction_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(d.date) AS month,
        COUNT(d.id) AS deduction_count,
        SUM(d.amount) AS total_amount
    FROM employees e
    LEFT JOIN deductions d ON e.id = d.employee_id AND YEAR(d.date) = p_year AND MONTH(d.date) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(d.date);
END//

DELIMITER ;

-- Buat stored procedure untuk get loan comparison
DELIMITER //

CREATE PROCEDURE get_loan_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(l.request_date) AS month,
        COUNT(l.id) AS loan_count,
        SUM(l.amount) AS total_amount
    FROM employees e
    LEFT JOIN employee_loans l ON e.id = l.employee_id AND YEAR(l.request_date) = p_year AND MONTH(l.request_date) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(l.request_date);
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi comparison
DELIMITER //

CREATE PROCEDURE get_kpi_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(k.date) AS month,
        COUNT(k.id) AS kpi_count,
        SUM(k.points) AS total_points
    FROM employees e
    LEFT JOIN kpi_points k ON e.id = k.employee_id AND YEAR(k.date) = p_year AND MONTH(k.date) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(k.date);
END//

DELIMITER ;

-- Buat stored procedure untuk get notification comparison
DELIMITER //

CREATE PROCEDURE get_notification_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(n.created_at) AS month,
        COUNT(n.id) AS notification_count
    FROM employees e
    LEFT JOIN notifications n ON e.id = n.employee_id AND YEAR(n.created_at) = p_year AND MONTH(n.created_at) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(n.created_at);
END//

DELIMITER ;

-- Buat stored procedure untuk get system log comparison
DELIMITER //

CREATE PROCEDURE get_system_log_comparison(IN p_employee_id INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        e.name AS employee_name,
        MONTH(l.created_at) AS month,
        COUNT(l.id) AS log_count
    FROM employees e
    LEFT JOIN system_logs l ON e.id = l.employee_id AND YEAR(l.created_at) = p_year AND MONTH(l.created_at) = p_month
    WHERE e.id = p_employee_id
    GROUP BY e.id, e.name, MONTH(l.created_at);
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance forecast
DELIMITER //

CREATE PROCEDURE get_attendance_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CASE 
            WHEN DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL n.day_number DAY)) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,
        CASE 
            WHEN DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL n.day_number DAY)) IN (1, 7) THEN 0
            ELSE 1
        END AS is_working_day
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket forecast
DELIMITER //

CREATE PROCEDURE get_ticket_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CEIL(RAND() * 5) AS estimated_tickets,
        CEIL(RAND() * 3) AS estimated_completed,
        CEIL(RAND() * 1) AS estimated_failed
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction forecast
DELIMITER //

CREATE PROCEDURE get_deduction_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CEIL(RAND() * 10000) AS estimated_deductions
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan forecast
DELIMITER //

CREATE PROCEDURE get_loan_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CEIL(RAND() * 2) AS estimated_loans,
        CEIL(RAND() * 500000) AS estimated_amount
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi forecast
DELIMITER //

CREATE PROCEDURE get_kpi_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CEIL(RAND() * 10) AS estimated_kpi_points
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification forecast
DELIMITER //

CREATE PROCEDURE get_notification_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CEIL(RAND() * 5) AS estimated_notifications
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log forecast
DELIMITER //

CREATE PROCEDURE get_system_log_forecast(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        DATE_ADD(CURDATE(), INTERVAL n.day_number DAY) AS forecast_date,
        CEIL(RAND() * 3) AS estimated_logs
    FROM (
        SELECT 0 AS day_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
    ) n
    WHERE n.day_number < p_days;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance anomaly detection
DELIMITER //

CREATE PROCEDURE get_attendance_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        a.check_in,
        a.status,
        CASE 
            WHEN a.status = 'late' AND TIMESTAMPDIFF(HOUR, a.check_in, '08:00') > 4 THEN 'Severe Late'
            WHEN a.status = 'late' AND TIMESTAMPDIFF(HOUR, a.check_in, '08:00') BETWEEN 2 AND 4 THEN 'Moderate Late'
            WHEN a.status = 'late' AND TIMESTAMPDIFF(HOUR, a.check_in, '08:00') BETWEEN 0 AND 2 THEN 'Mild Late'
            ELSE 'Normal'
        END AS anomaly_level,
        TIMESTAMPDIFF(HOUR, a.check_in, '08:00') AS hours_late
    FROM attendance a
    WHERE a.employee_id = p_employee_id 
    AND a.check_in >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    AND a.status = 'late'
    ORDER BY a.check_in DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket anomaly detection
DELIMITER //

CREATE PROCEDURE get_ticket_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        t.ticket_number,
        t.status,
        t.assigned_at,
        t.completed_at,
        TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at) AS completion_time,
        CASE 
            WHEN TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at) > 8 THEN 'Slow Completion'
            WHEN TIMESTAMPDIFF(HOUR, t.assigned_at, t.completed_at) < 2 THEN 'Fast Completion'
            ELSE 'Normal'
        END AS anomaly_level
    FROM tickets t
    WHERE t.employee_id = p_employee_id 
    AND t.status = 'completed'
    AND t.completed_at >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    ORDER BY t.completed_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction anomaly detection
DELIMITER //

CREATE PROCEDURE get_deduction_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        d.type,
        d.amount,
        d.reason,
        d.date,
        CASE 
            WHEN d.amount > (SELECT AVG(amount) FROM deductions WHERE employee_id = p_employee_id AND date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) * 2 THEN 'High Deduction'
            ELSE 'Normal'
        END AS anomaly_level
    FROM deductions d
    WHERE d.employee_id = p_employee_id 
    AND d.date >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    ORDER BY d.date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan anomaly detection
DELIMITER //

CREATE PROCEDURE get_loan_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        l.amount,
        l.request_date,
        l.status,
        l.approval_date,
        TIMESTAMPDIFF(DAY, l.request_date, l.approval_date) AS approval_days,
        CASE 
            WHEN TIMESTAMPDIFF(DAY, l.request_date, l.approval_date) > 7 THEN 'Slow Approval'
            ELSE 'Normal'
        END AS anomaly_level
    FROM employee_loans l
    WHERE l.employee_id = p_employee_id 
    AND l.request_date >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    ORDER BY l.request_date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi anomaly detection
DELIMITER //

CREATE PROCEDURE get_kpi_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        k.points,
        k.reason,
        k.date,
        CASE 
            WHEN k.points > (SELECT AVG(points) FROM kpi_points WHERE employee_id = p_employee_id AND date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) * 2 THEN 'High KPI'
            WHEN k.points < (SELECT AVG(points) FROM kpi_points WHERE employee_id = p_employee_id AND date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) / 2 THEN 'Low KPI'
            ELSE 'Normal'
        END AS anomaly_level
    FROM kpi_points k
    WHERE k.employee_id = p_employee_id 
    AND k.date >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    ORDER BY k.date DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification anomaly detection
DELIMITER //

CREATE PROCEDURE get_notification_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        n.type,
        n.message,
        n.created_at,
        n.is_read,
        CASE 
            WHEN n.type = 'new_ticket' AND n.created_at < DATE_SUB(CURDATE(), INTERVAL 1 DAY) THEN 'Overdue Ticket'
            WHEN n.type = 'checkin_reminder' AND n.created_at < DATE_SUB(CURDATE(), INTERVAL 1 DAY) THEN 'Overdue Check-in'
            ELSE 'Normal'
        END AS anomaly_level
    FROM notifications n
    WHERE n.employee_id = p_employee_id 
    AND n.created_at >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    ORDER BY n.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log anomaly detection
DELIMITER //

CREATE PROCEDURE get_system_log_anomaly_detection(IN p_employee_id INT, IN p_days INT)
BEGIN
    SELECT
        l.action,
        l.details,
        l.created_at,
        CASE 
            WHEN l.action LIKE 'error_%' THEN 'Error'
            WHEN l.action LIKE 'failed_%' THEN 'Failure'
            ELSE 'Normal'
        END AS anomaly_level
    FROM system_logs l
    WHERE (l.employee_id = p_employee_id OR l.employee_id IS NULL) 
    AND l.created_at >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    ORDER BY l.created_at DESC;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance recommendations
DELIMITER //

CREATE PROCEDURE get_attendance_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Improve punctuality by arriving 15 minutes before official start time' AS recommendation,
        'Set multiple alarms and prepare the night before' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM attendance 
        WHERE employee_id = p_employee_id 
        AND status = 'late' 
        AND TIMESTAMPDIFF(HOUR, check_in, '08:00') > 2
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket recommendations
DELIMITER //

CREATE PROCEDURE get_ticket_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Focus on completing tickets within SLA time' AS recommendation,
        'Prioritize tickets by urgency and complexity' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM tickets 
        WHERE employee_id = p_employee_id 
        AND status = 'failed'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction recommendations
DELIMITER //

CREATE PROCEDURE get_deduction_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Review work processes to minimize deductions' AS recommendation,
        'Seek clarification on unclear tasks' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM deductions 
        WHERE employee_id = p_employee_id 
        AND type = 'ticket'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get loan recommendations
DELIMITER //

CREATE PROCEDURE get_loan_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Manage finances better to reduce loan dependency' AS recommendation,
        'Create budget plan and emergency fund' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM employee_loans 
        WHERE employee_id = p_employee_id 
        AND status = 'approved'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi recommendations
DELIMITER //

CREATE PROCEDURE get_kpi_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Continue excellent performance and seek new challenges' AS recommendation,
        'Mentor junior technicians and share best practices' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM kpi_points 
        WHERE employee_id = p_employee_id 
        AND points > 5
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get notification recommendations
DELIMITER //

CREATE PROCEDURE get_notification_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Check notifications regularly and respond promptly' AS recommendation,
        'Enable push notifications for important updates' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM notifications 
        WHERE employee_id = p_employee_id 
        AND is_read = 0
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get system log recommendations
DELIMITER //

CREATE PROCEDURE get_system_log_recommendations(IN p_employee_id INT)
BEGIN
    SELECT
        'Review system logs for performance insights' AS recommendation,
        'Address any recurring errors or warnings' AS action
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM system_logs 
        WHERE (employee_id = p_employee_id OR employee_id IS NULL)
        AND action LIKE 'error_%'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance insights
DELIMITER //

CREATE PROCEDURE get_attendance_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total working days: ' || COUNT(DISTINCT DATE(check_in)) AS insight,
        'Average work hours per day: ' || ROUND(AVG(TIMESTAMPDIFF(HOUR, check_in, check_out)), 2) AS value,
        'Punctuality rate: ' || ROUND(COUNT(CASE WHEN status = 'present' THEN 1 END) / COUNT(*) * 100, 2) || '%' AS percentage
    FROM attendance
    WHERE employee_id = p_employee_id AND YEAR(check_in) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket insights
DELIMITER //

CREATE PROCEDURE get_ticket_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total tickets handled: ' || COUNT(*) AS insight,
        'Completion rate: ' || ROUND(COUNT(CASE WHEN status = 'completed' THEN 1 END) / COUNT(*) * 100, 2) || '%' AS value,
        'Average completion time: ' || ROUND(AVG(TIMESTAMPDIFF(HOUR, assigned_at, completed_at)), 2) || ' hours' AS additional
    FROM tickets
    WHERE employee_id = p_employee_id AND YEAR(assigned_at) = p_year AND status = 'completed';
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction insights
DELIMITER //

CREATE PROCEDURE get_deduction_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total deductions: Rp ' || SUM(amount) AS insight,
        'Deduction sources: ' || GROUP_CONCAT(DISTINCT type) AS value,
        'Major deduction: Rp ' || MAX(amount) AS additional
    FROM deductions
    WHERE employee_id = p_employee_id AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan insights
DELIMITER //

CREATE PROCEDURE get_loan_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total loans: ' || COUNT(*) AS insight,
        'Loan status: ' || GROUP_CONCAT(DISTINCT status) AS value,
        'Total amount: Rp ' || SUM(amount) AS additional
    FROM employee_loans
    WHERE employee_id = p_employee_id AND YEAR(request_date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi insights
DELIMITER //

CREATE PROCEDURE get_kpi_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total KPI points: ' || SUM(points) AS insight,
        'KPI sources: ' || GROUP_CONCAT(DISTINCT reason) AS value,
        'Top achievement: ' || (SELECT reason FROM kpi_points WHERE employee_id = p_employee_id AND YEAR(date) = p_year ORDER BY points DESC LIMIT 1) AS additional
    FROM kpi_points
    WHERE employee_id = p_employee_id AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification insights
DELIMITER //

CREATE PROCEDURE get_notification_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total notifications: ' || COUNT(*) AS insight,
        'Notification types: ' || GROUP_CONCAT(DISTINCT type) AS value,
        'Unread notifications: ' || COUNT(CASE WHEN is_read = 0 THEN 1 END) AS additional
    FROM notifications
    WHERE employee_id = p_employee_id AND YEAR(created_at) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log insights
DELIMITER //

CREATE PROCEDURE get_system_log_insights(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Total system logs: ' || COUNT(*) AS insight,
        'Log types: ' || GROUP_CONCAT(DISTINCT action) AS value,
        'Recent activity: ' || MAX(created_at) AS additional
    FROM system_logs
    WHERE (employee_id = p_employee_id OR employee_id IS NULL) AND YEAR(created_at) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance goals
DELIMITER //

CREATE PROCEDURE get_attendance_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Achieve 95% punctuality rate' AS goal,
        'Target: 0 late days per month' AS target,
        'Current: ' || COUNT(CASE WHEN status = 'late' THEN 1 END) || ' late days this month' AS current
    FROM attendance
    WHERE employee_id = p_employee_id AND MONTH(check_in) = MONTH(CURDATE());
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket goals
DELIMITER //

CREATE PROCEDURE get_ticket_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Complete 90% of assigned tickets' AS goal,
        'Target: 0 failed tickets per month' AS target,
        'Current: ' || COUNT(CASE WHEN status = 'failed' THEN 1 END) || ' failed tickets this month' AS current
    FROM tickets
    WHERE employee_id = p_employee_id AND MONTH(assigned_at) = MONTH(CURDATE());
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction goals
DELIMITER //

CREATE PROCEDURE get_deduction_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Minimize deductions to below 5% of salary' AS goal,
        'Target: Rp 0 in deductions' AS target,
        'Current: Rp ' || SUM(amount) || ' in deductions this month' AS current
    FROM deductions
    WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE());
END//

DELIMITER ;

-- Buat stored procedure untuk get loan goals
DELIMITER //

CREATE PROCEDURE get_loan_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Reduce loan dependency by 50%' AS goal,
        'Target: 0 active loans' AS target,
        'Current: ' || COUNT(CASE WHEN status = 'approved' THEN 1 END) || ' active loans' AS current
    FROM employee_loans
    WHERE employee_id = p_employee_id AND status = 'approved';
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi goals
DELIMITER //

CREATE PROCEDURE get_kpi_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Achieve 100 KPI points per quarter' AS goal,
        'Target: 33 points per month' AS target,
        'Current: ' || SUM(points) || ' points this month' AS current
    FROM kpi_points
    WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE());
END//

DELIMITER ;

-- Buat stored procedure untuk get notification goals
DELIMITER //

CREATE PROCEDURE get_notification_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Respond to all notifications within 24 hours' AS goal,
        'Target: 0 unread notifications' AS target,
        'Current: ' || COUNT(CASE WHEN is_read = 0 THEN 1 END) || ' unread notifications' AS current
    FROM notifications
    WHERE employee_id = p_employee_id;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log goals
DELIMITER //

CREATE PROCEDURE get_system_log_goals(IN p_employee_id INT)
BEGIN
    SELECT
        'Maintain error-free system operations' AS goal,
        'Target: 0 error logs' AS target,
        'Current: ' || COUNT(CASE WHEN action LIKE 'error_%' THEN 1 END) || ' error logs' AS current
    FROM system_logs
    WHERE (employee_id = p_employee_id OR employee_id IS NULL);
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance achievements
DELIMITER //

CREATE PROCEDURE get_attendance_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Perfect Attendance Award' AS achievement,
        'Achieved 100% punctuality for ' || COUNT(DISTINCT DATE(check_in)) || ' days' AS description
    FROM attendance
    WHERE employee_id = p_employee_id 
    AND YEAR(check_in) = p_year 
    AND status = 'present';
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket achievements
DELIMITER //

CREATE PROCEDURE get_ticket_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Ticket Master Award' AS achievement,
        'Completed ' || COUNT(*) || ' tickets with 100% success rate' AS description
    FROM tickets
    WHERE employee_id = p_employee_id 
    AND YEAR(assigned_at) = p_year 
    AND status = 'completed';
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction achievements
DELIMITER //

CREATE PROCEDURE get_deduction_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Deduction Free Award' AS achievement,
        'No deductions recorded for the entire year' AS description
    FROM deductions
    WHERE employee_id = p_employee_id 
    AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan achievements
DELIMITER //

CREATE PROCEDURE get_loan_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Financial Responsibility Award' AS achievement,
        'Successfully repaid all loans on time' AS description
    FROM employee_loans
    WHERE employee_id = p_employee_id 
    AND YEAR(repayment_date) = p_year 
    AND status = 'repaid';
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi achievements
DELIMITER //

CREATE PROCEDURE get_kpi_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'KPI Excellence Award' AS achievement,
        'Achieved ' || SUM(points) || ' KPI points' AS description
    FROM kpi_points
    WHERE employee_id = p_employee_id 
    AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification achievements
DELIMITER //

CREATE PROCEDURE get_notification_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Notification Master Award' AS achievement,
        'Responded to all notifications promptly' AS description
    FROM notifications
    WHERE employee_id = p_employee_id 
    AND YEAR(created_at) = p_year 
    AND is_read = 1;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log achievements
DELIMITER //

CREATE PROCEDURE get_system_log_achievements(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'System Excellence Award' AS achievement,
        'Maintained error-free system operations' AS description
    FROM system_logs
    WHERE (employee_id = p_employee_id OR employee_id IS NULL) 
    AND YEAR(created_at) = p_year 
    AND action NOT LIKE 'error_%';
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance challenges
DELIMITER //

CREATE PROCEDURE get_attendance_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Improve punctuality' AS challenge,
        'Addressed ' || COUNT(CASE WHEN status = 'late' THEN 1 END) || ' late days' AS progress
    FROM attendance
    WHERE employee_id = p_employee_id AND YEAR(check_in) = p_year AND status = 'late';
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket challenges
DELIMITER //

CREATE PROCEDURE get_ticket_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Reduce ticket failures' AS challenge,
        'Addressed ' || COUNT(CASE WHEN status = 'failed' THEN 1 END) || ' failed tickets' AS progress
    FROM tickets
    WHERE employee_id = p_employee_id AND YEAR(assigned_at) = p_year AND status = 'failed';
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction challenges
DELIMITER //

CREATE PROCEDURE get_deduction_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Minimize deductions' AS challenge,
        'Addressed Rp ' || SUM(amount) || ' in deductions' AS progress
    FROM deductions
    WHERE employee_id = p_employee_id AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan challenges
DELIMITER //

CREATE PROCEDURE get_loan_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Manage loan dependency' AS challenge,
        'Addressed ' || COUNT(CASE WHEN status = 'approved' THEN 1 END) || ' active loans' AS progress
    FROM employee_loans
    WHERE employee_id = p_employee_id AND YEAR(request_date) = p_year AND status = 'approved';
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi challenges
DELIMITER //

CREATE PROCEDURE get_kpi_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Increase KPI points' AS challenge,
        'Addressed ' || SUM(points) || ' KPI points' AS progress
    FROM kpi_points
    WHERE employee_id = p_employee_id AND YEAR(date) = p_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get notification challenges
DELIMITER //

CREATE PROCEDURE get_notification_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Reduce unread notifications' AS challenge,
        'Addressed ' || COUNT(CASE WHEN is_read = 0 THEN 1 END) || ' unread notifications' AS progress
    FROM notifications
    WHERE employee_id = p_employee_id AND YEAR(created_at) = p_year AND is_read = 0;
END//

DELIMITER ;

-- Buat stored procedure untuk get system log challenges
DELIMITER //

CREATE PROCEDURE get_system_log_challenges(IN p_employee_id INT, IN p_year INT)
BEGIN
    SELECT
        'Address system errors' AS challenge,
        'Addressed ' || COUNT(CASE WHEN action LIKE 'error_%' THEN 1 END) || ' error logs' AS progress
    FROM system_logs
    WHERE (employee_id = p_employee_id OR employee_id IS NULL) AND YEAR(created_at) = p_year AND action LIKE 'error_%';
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance improvement plan
DELIMITER //

CREATE PROCEDURE get_attendance_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Set alarm 15 minutes before work' AS action,
        'Prepare clothes and equipment the night before' AS detail,
        'Track progress weekly' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM attendance 
        WHERE employee_id = p_employee_id 
        AND status = 'late'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket improvement plan
DELIMITER //

CREATE PROCEDURE get_ticket_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Prioritize tickets by urgency' AS action,
        'Seek clarification on unclear tasks' AS detail,
        'Review completed tickets for learning' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM tickets 
        WHERE employee_id = p_employee_id 
        AND status = 'failed'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction improvement plan
DELIMITER //

CREATE PROCEDURE get_deduction_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Review work processes for efficiency' AS action,
        'Seek feedback from supervisors' AS detail,
        'Track deductions monthly' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM deductions 
        WHERE employee_id = p_employee_id 
        AND type = 'ticket'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get loan improvement plan
DELIMITER //

CREATE PROCEDURE get_loan_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Create budget and emergency fund' AS action,
        'Reduce unnecessary expenses' AS detail,
        'Track loan repayments' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM employee_loans 
        WHERE employee_id = p_employee_id 
        AND status = 'approved'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi improvement plan
DELIMITER //

CREATE PROCEDURE get_kpi_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Seek new challenges and responsibilities' AS action,
        'Mentor junior team members' AS detail,
        'Track KPI points monthly' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM kpi_points 
        WHERE employee_id = p_employee_id 
        AND points < 5
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get notification improvement plan
DELIMITER //

CREATE PROCEDURE get_notification_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Enable push notifications' AS action,
        'Check notifications regularly' AS detail,
        'Respond within 24 hours' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM notifications 
        WHERE employee_id = p_employee_id 
        AND is_read = 0
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get system log improvement plan
DELIMITER //

CREATE PROCEDURE get_system_log_improvement_plan(IN p_employee_id INT)
BEGIN
    SELECT
        'Review error logs and address issues' AS action,
        'Implement monitoring and alerts' AS detail,
        'Track system performance' AS monitoring
    FROM dual
    WHERE EXISTS (
        SELECT 1 FROM system_logs 
        WHERE (employee_id = p_employee_id OR employee_id IS NULL) 
        AND action LIKE 'error_%'
        LIMIT 1
    );
END//

DELIMITER ;

-- Buat stored procedure untuk get attendance dashboard data
DELIMITER //

CREATE PROCEDURE get_attendance_dashboard_data(IN p_employee_id INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND DATE(check_in) = CURDATE()) AS today_attendance,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND status = 'present' AND DATE(check_in) = CURDATE()) AS present_today,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND status = 'late' AND DATE(check_in) = CURDATE()) AS late_today,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND status = 'absent' AND DATE(check_in) = CURDATE()) AS absent_today,
        (SELECT AVG(TIMESTAMPDIFF(HOUR, check_in, check_out)) FROM attendance WHERE employee_id = p_employee_id AND DATE(check_in) = CURDATE()) AS avg_work_hours_today,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND MONTH(check_in) = MONTH(CURDATE())) AS month_attendance,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND status = 'present' AND MONTH(check_in) = MONTH(CURDATE())) AS present_month,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND status = 'late' AND MONTH(check_in) = MONTH(CURDATE())) AS late_month,
        (SELECT COUNT(*) FROM attendance WHERE employee_id = p_employee_id AND status = 'absent' AND MONTH(check_in) = MONTH(CURDATE())) AS absent_month,
        (SELECT AVG(TIMESTAMPDIFF(HOUR, check_in, check_out)) FROM attendance WHERE employee_id = p_employee_id AND MONTH(check_in) = MONTH(CURDATE())) AS avg_work_hours_month;
END//

DELIMITER ;

-- Buat stored procedure untuk get ticket dashboard data
DELIMITER //

CREATE PROCEDURE get_ticket_dashboard_data(IN p_employee_id INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'pending' AND DATE(assigned_at) = CURDATE()) AS pending_tickets_today,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'in_progress' AND DATE(assigned_at) = CURDATE()) AS in_progress_tickets_today,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'completed' AND DATE(assigned_at) = CURDATE()) AS completed_tickets_today,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'failed' AND DATE(assigned_at) = CURDATE()) AS failed_tickets_today,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'pending' AND MONTH(assigned_at) = MONTH(CURDATE())) AS pending_tickets_month,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'in_progress' AND MONTH(assigned_at) = MONTH(CURDATE())) AS in_progress_tickets_month,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'completed' AND MONTH(assigned_at) = MONTH(CURDATE())) AS completed_tickets_month,
        (SELECT COUNT(*) FROM tickets WHERE employee_id = p_employee_id AND status = 'failed' AND MONTH(assigned_at) = MONTH(CURDATE())) AS failed_tickets_month,
        (SELECT AVG(TIMESTAMPDIFF(HOUR, assigned_at, completed_at)) FROM tickets WHERE employee_id = p_employee_id AND status = 'completed' AND DATE(assigned_at) = CURDATE()) AS avg_completion_time_today,
        (SELECT AVG(TIMESTAMPDIFF(HOUR, assigned_at, completed_at)) FROM tickets WHERE employee_id = p_employee_id AND status = 'completed' AND MONTH(assigned_at) = MONTH(CURDATE())) AS avg_completion_time_month;
END//

DELIMITER ;

-- Buat stored procedure untuk get deduction dashboard data
DELIMITER //

CREATE PROCEDURE get_deduction_dashboard_data(IN p_employee_id INT)
BEGIN
    SELECT
        (SELECT SUM(amount) FROM deductions WHERE employee_id = p_employee_id AND DATE(date) = CURDATE()) AS deductions_today,
        (SELECT SUM(amount) FROM deductions WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE())) AS deductions_month,
        (SELECT SUM(amount) FROM deductions WHERE employee_id = p_employee_id AND YEAR(date) = YEAR(CURDATE())) AS deductions_year,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND DATE(date) = CURDATE() AND type = 'late') AS late_deductions_today,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE()) AND type = 'late') AS late_deductions_month,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND YEAR(date) = YEAR(CURDATE()) AND type = 'late') AS late_deductions_year,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND DATE(date) = CURDATE() AND type = 'ticket') AS ticket_deductions_today,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE()) AND type = 'ticket') AS ticket_deductions_month,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND YEAR(date) = YEAR(CURDATE()) AND type = 'ticket') AS ticket_deductions_year,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND DATE(date) = CURDATE() AND type = 'loan') AS loan_deductions_today,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE()) AND type = 'loan') AS loan_deductions_month,
        (SELECT COUNT(*) FROM deductions WHERE employee_id = p_employee_id AND YEAR(date) = YEAR(CURDATE()) AND type = 'loan') AS loan_deductions_year;
END//

DELIMITER ;

-- Buat stored procedure untuk get loan dashboard data
DELIMITER //

CREATE PROCEDURE get_loan_dashboard_data(IN p_employee_id INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'pending' AND DATE(request_date) = CURDATE()) AS pending_loans_today,
        (SELECT COUNT(*) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'approved' AND DATE(approval_date) = CURDATE()) AS approved_loans_today,
        (SELECT COUNT(*) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'repaid' AND DATE(repayment_date) = CURDATE()) AS repaid_loans_today,
        (SELECT COUNT(*) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'pending' AND MONTH(request_date) = MONTH(CURDATE())) AS pending_loans_month,
        (SELECT COUNT(*) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'approved' AND MONTH(approval_date) = MONTH(CURDATE())) AS approved_loans_month,
        (SELECT COUNT(*) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'repaid' AND MONTH(repayment_date) = MONTH(CURDATE())) AS repaid_loans_month,
        (SELECT SUM(amount) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'approved') AS total_approved_loans,
        (SELECT SUM(amount) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'repaid') AS total_repaid_loans,
        (SELECT SUM(amount) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'approved' AND MONTH(approval_date) = MONTH(CURDATE())) AS approved_loans_this_month,
        (SELECT SUM(amount) FROM employee_loans WHERE employee_id = p_employee_id AND status = 'repaid' AND MONTH(repayment_date) = MONTH(CURDATE())) AS repaid_loans_this_month;
END//

DELIMITER ;

-- Buat stored procedure untuk get kpi dashboard data
DELIMITER //

CREATE PROCEDURE get_kpi_dashboard_data(IN p_employee_id INT)
BEGIN
    SELECT
        (SELECT COUNT(*) FROM kpi_points WHERE employee_id = p_employee_id AND DATE(date) = CURDATE()) AS kpi_entries_today,
        (SELECT SUM(points) FROM kpi_points WHERE employee_id = p_employee_id AND DATE(date) = CURDATE()) AS kpi_points_today,
        (SELECT COUNT(*) FROM kpi_points WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE())) AS kpi_entries_month,
        (SELECT SUM(points) FROM kpi_points WHERE employee_id = p_employee_id AND MONTH(date) = MONTH(CURDATE())) AS kpi_points_month,
        (SELECT COUNT