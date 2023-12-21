# Hospital Database README

## Overview

This Java program (`Reporting.java`) provides a command-line interface to access and retrieve information from the hospital database. The program utilizes JDBC to connect to the Oracle database, execute queries, and display reports. It includes functionality for reporting patients' basic information, doctors' basic information, admissions information, and updating admission payments.

## Table of Contents

1. [Installation](#installation)
2. [Database Schema](#database-schema)
3. [Usage](#usage)
4. [Tables](#tables)
   - [Employee](#employee)
   - [Doctor](#doctor)
   - [EquipmentTechnician](#equipmenttechnician)
   - [EquipmentType](#equipmenttype)
   - [CanRepairEquipment](#canrepairequipment)
   - [Room](#room)
   - [RoomService](#roomservice)
   - [RoomAccess](#roomaccess)
   - [Equipment](#equipment)
   - [Patient](#patient)
   - [Admission](#admission)
   - [Examine](#examine)
   - [StayIn](#stayin)
5. [Views](#views)
6. [Triggers](#triggers)
7. [Usage in Java Program](#usage-in-java-program)
8. [Contributing](#contributing)
9. [License](#license)

## Installation

Ensure that you have the necessary dependencies for the Java program, including the Oracle JDBC Driver. Follow the instructions in the Java program comments for setup.

## Database Schema

The program interacts with a hospital database, and its structure is defined by the SQL script (`"Phase3 copy".sql`). Refer to the script for the database schema.

## Usage

The program is designed to be run from the command line with two required arguments: `<username>` and `<password>`. Additionally, optional arguments can be provided to specify the type of report to generate. The program supports reporting patients' basic information, doctors' basic information, admissions information, and updating admission payments.

## Tables

### Employee

- Contains information about employees, including their employee ID, name, salary, job title, office number, rank, supervisor ID, and address.

### Doctor

- Stores details about doctors, such as their employee ID, gender, specialty, and alma mater. Linked to the Employee table.

### EquipmentTechnician

- Stores information about equipment technicians, linked to the Employee table.

### EquipmentType

- Manages different equipment types, including equipment ID, description, model, instructions, and number of units.

### CanRepairEquipment

- Establishes relationships between employees and equipment types, indicating which employees can repair which equipment types.

### Room

- Manages rooms in the hospital, including room number and occupancy status.

### RoomService

- Defines room services that can be provided, linked to the Room table.

### RoomAccess

- Manages access to rooms by employees, linked to the Room table.

### Equipment

- Contains information about equipment, including serial number, type ID, purchase year, last inspection date, and room number.

### Patient

- Stores patient information, including social security number, name, address, and telephone number.

### Admission

- Manages patient admissions, including admission number, admission date, leave date, total payment, insurance payment, patient SSN, and future visit date.

### Examine

- Tracks examinations conducted by doctors during patient admissions.

### StayIn

- Records the stays of patients in rooms during admissions.

## Views

The script includes views that provide convenient ways to retrieve and present data, enhancing the user experience.

## Triggers

The script includes triggers to automate actions in response to specific events, ensuring data integrity and consistency.

## Usage in Java Program

The Java program (`Reporting.java`) demonstrates how to connect to the database using JDBC, execute SQL queries, and generate reports. It includes functionality for reporting patients' basic information, doctors' basic information, admissions information, and updating admission payments.

## Contributing

If you find any issues or have suggestions for improvements, feel free to contribute by submitting a pull request. Your contributions are highly appreciated.

## License

This hospital database and the Java program are provided under the [MIT License](LICENSE). Feel free to use, modify, and distribute them as needed, but please include the original license file.
