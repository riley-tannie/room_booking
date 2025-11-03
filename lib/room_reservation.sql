-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 02, 2025 at 06:52 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `room_reservation`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` varchar(50) NOT NULL,
  `student_id` varchar(20) NOT NULL,
  `room_id` varchar(20) NOT NULL,
  `booking_date` date NOT NULL,
  `time_slot` varchar(20) NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `booked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `approved_by` varchar(20) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` enum('Study Room','Multimedia Room','Lecture Hall') NOT NULL,
  `location` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_disabled` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `name`, `category`, `location`, `description`, `image_url`, `is_disabled`, `created_at`) VALUES
('room_001', 'Study Room 1', 'Study Room', '2nd Floor, D1, Study Area', 'A quiet study room with individual desks and power outlets', 'assets/images/study_room1.jpg', 0, '2025-11-01 14:32:10'),
('room_002', 'Multimedia Room 1', 'Multimedia Room', '1st Floor, C2, Multimedia Zone', 'Equipped with large screen displays and audio systems', 'assets/images/multimedia_1.jpg', 0, '2025-11-01 14:32:10'),
('room_003', 'Lecture Hall 1', 'Lecture Hall', '3rd Floor, E1, Academic Wing', 'Large capacity hall with projector and sound system', 'assets/images/lecture_hall1.jpg', 0, '2025-11-01 14:32:10'),
('room_004', 'Study Room 2', 'Study Room', 'Ground Floor, B1, Study Area', 'Small collaborative space with whiteboards', 'assets/images/study_room2.jpg', 0, '2025-11-01 14:32:10'),
('room_005', 'Study Room 3', 'Study Room', '3rd Floor, E2, Study Area', 'Quiet study room with natural lighting', 'assets/images/study_room3.jpg', 0, '2025-11-01 14:32:10'),
('room_006', 'Multimedia Room 2', 'Multimedia Room', '2nd Floor, D2, Multimedia Zone', 'Advanced multimedia room with 4K displays', 'assets/images/multimedia_2.jpg', 0, '2025-11-01 14:32:10'),
('room_007', 'Lecture Hall 2', 'Lecture Hall', '4th Floor, F1, Academic Wing', 'Medium capacity hall with advanced audio system', 'assets/images/lecture_hall2.jpg', 0, '2025-11-01 14:32:10'),
('room_008', 'Study Room 4', 'Study Room', '1st Floor, A1, Study Area', 'Group study room with large table', 'assets/images/study_room4.jpg', 0, '2025-11-01 14:32:10'),
('room_009', 'Multimedia Room 3', 'Multimedia Room', '3rd Floor, E3, Multimedia Zone', 'Video conferencing enabled multimedia room', 'assets/images/multimedia_3.jpg', 0, '2025-11-01 14:32:10'),
('room_010', 'Lecture Hall 3', 'Lecture Hall', '2nd Floor, C1, Academic Wing', 'Small lecture hall for seminars', 'assets/images/lecture_hall3.jpg', 0, '2025-11-01 14:32:10');

-- --------------------------------------------------------

--
-- Table structure for table `room_availability`
--

CREATE TABLE `room_availability` (
  `id` int(11) NOT NULL,
  `room_id` varchar(20) NOT NULL,
  `availability_date` date NOT NULL,
  `time_slot` varchar(20) NOT NULL,
  `status` enum('free','pending','reserved','disabled') DEFAULT 'free',
  `student_id` varchar(20) DEFAULT NULL,
  `booking_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(97) NOT NULL,
  `role` enum('student','lecturer','staff') NOT NULL,
  `faculty` varchar(100) DEFAULT NULL,
  `points` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password`, `role`, `faculty`, `points`, `created_at`) VALUES
('LEC10001', 'Dr. Smith', 'lecturer@mfu.ac.th', '111111', 'lecturer', 'Faculty of Engineering', 0, '2025-11-01 14:32:10'),
('STAFF001', 'Admin Staff', 'staff@mfu.th', '123456', 'staff', 'Administration', 0, '2025-11-01 14:32:10'),
('STU12345', 'Riley Tan', 'student@lamduan.mfu.ac.th', '123456', 'student', 'Faculty of Engineering', 320, '2025-11-01 14:32:10'),
('6631501142', 'Riley Tang', '6631501142@lamduan.mfu.ac.th', '654321', 'student', 'Faculty of Engineering', 250, '2025-11-01 14:32:10');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `room_id` (`room_id`),
  ADD KEY `approved_by` (`approved_by`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `room_availability`
--
ALTER TABLE `room_availability`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_room_date_slot` (`room_id`,`availability_date`,`time_slot`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `room_availability`
--
ALTER TABLE `room_availability`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `room_availability`
--
ALTER TABLE `room_availability`
  ADD CONSTRAINT `room_availability_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  ADD CONSTRAINT `room_availability_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `room_availability_ibfk_3` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- Clear existing room availability data
DELETE FROM room_availability;

-- Insert sample room availability data with CORRECT time slots for TODAY
INSERT INTO `room_availability` (`room_id`, `availability_date`, `time_slot`, `status`, `student_id`, `booking_id`) VALUES
-- Room 001: Mixed statuses
('room_001', CURDATE(), '08:00-10:00', 'free', NULL, NULL),
('room_001', CURDATE(), '10:00-12:00', 'pending', '6631501142', NULL),
('room_001', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_001', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 002: More mixed statuses
('room_002', CURDATE(), '08:00-10:00', 'reserved', '6631501142', NULL),
('room_002', CURDATE(), '10:00-12:00', 'free', NULL, NULL),
('room_002', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_002', CURDATE(), '15:00-17:00', 'pending', '6631501142', NULL),

-- Room 003: Different pattern
('room_003', CURDATE(), '08:00-10:00', 'free', NULL, NULL),
('room_003', CURDATE(), '10:00-12:00', 'free', NULL, NULL),
('room_003', CURDATE(), '13:00-15:00', 'reserved', '6631501142', NULL),
('room_003', CURDATE(), '15:00-17:00', 'disabled', NULL, NULL),

-- Room 004: Mostly available
('room_004', CURDATE(), '08:00-10:00', 'free', NULL, NULL),
('room_004', CURDATE(), '10:00-12:00', 'free', NULL, NULL),
('room_004', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_004', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 005: All free
('room_005', CURDATE(), '08:00-10:00', 'free', NULL, NULL),
('room_005', CURDATE(), '10:00-12:00', 'free', NULL, NULL),
('room_005', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_005', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 006: Morning busy
('room_006', CURDATE(), '08:00-10:00', 'reserved', '6631501142', NULL),
('room_006', CURDATE(), '10:00-12:00', 'pending', '6631501142', NULL),
('room_006', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_006', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 007: Afternoon free
('room_007', CURDATE(), '08:00-10:00', 'disabled', NULL, NULL),
('room_007', CURDATE(), '10:00-12:00', 'disabled', NULL, NULL),
('room_007', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_007', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 008: Evening only
('room_008', CURDATE(), '08:00-10:00', 'reserved', '6631501142', NULL),
('room_008', CURDATE(), '10:00-12:00', 'reserved', '6631501142', NULL),
('room_008', CURDATE(), '13:00-15:00', 'pending', '6631501142', NULL),
('room_008', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 009: All day available
('room_009', CURDATE(), '08:00-10:00', 'free', NULL, NULL),
('room_009', CURDATE(), '10:00-12:00', 'free', NULL, NULL),
('room_009', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_009', CURDATE(), '15:00-17:00', 'free', NULL, NULL),

-- Room 010: Limited availability
('room_010', CURDATE(), '08:00-10:00', 'free', NULL, NULL),
('room_010', CURDATE(), '10:00-12:00', 'disabled', NULL, NULL),
('room_010', CURDATE(), '13:00-15:00', 'free', NULL, NULL),
('room_010', CURDATE(), '15:00-17:00', 'disabled', NULL, NULL);

-- Add some sample bookings for the student
INSERT INTO `bookings` (`id`, `student_id`, `room_id`, `booking_date`, `time_slot`, `status`, `booked_at`) VALUES
('book_001', '6631501142', 'room_001', CURDATE(), '10:00-12:00', 'Pending', NOW()),
('book_002', '6631501142', 'room_002', CURDATE(), '08:00-10:00', 'Approved', NOW()),
('book_003', '6631501142', 'room_003', CURDATE(), '13:00-15:00', 'Approved', NOW()),
('book_004', '6631501142', 'room_006', CURDATE(), '08:00-10:00', 'Approved', NOW()),
('book_005', '6631501142', 'room_008', CURDATE(), '13:00-15:00', 'Pending', NOW());