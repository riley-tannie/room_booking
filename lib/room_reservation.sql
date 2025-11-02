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
('room_004', 'Study Room 2', 'Study Room', 'Ground Floor, B1, Study Area', 'Small collaborative space with whiteboards', 'assets/images/study_room2.jpg', 0, '2025-11-01 14:32:10');

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
('LEC10001', 'Dr. Smith', 'lecturer@mfu.ac.th', '$argon2id$v=19$m=19456,t=2,p=1$q0wW1d5n7P3r9s2x$RrQVctU1bQ2W3e4r5t6y7u8i9o0p', 'lecturer', 'Faculty of Engineering', 0, '2025-11-01 14:32:10'),
('STAFF001', 'Admin Staff', 'staff@mfu.th', '$argon2id$v=19$m=19456,t=2,p=1$q0wW1d5n7P3r9s2x$RrQVctU1bQ2W3e4r5t6y7u8i9o0p', 'staff', 'Administration', 0, '2025-11-01 14:32:10'),
('STU12345', 'Riley Tan', 'student@lamduan.mfu.ac.th', '$argon2id$v=19$m=19456,t=2,p=1$q0wW1d5n7P3r9s2x$RrQVctU1bQ2W3e4r5t6y7u8i9o0p', 'student', 'Faculty of Engineering', 320, '2025-11-01 14:32:10');

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
