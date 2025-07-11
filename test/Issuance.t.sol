// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/Issuance.sol";

contract IssuanceTest is Test {
    Issuance issuance;
    address admin = address(0x1);
    address student1 = address(0x2);
    address nonAdmin = address(0x3);
    address newAdmin = address(0x4);

    event CertificateIssued(
        address indexed student, 
        uint256 certificateId, 
        string studentName, 
        string course, 
        uint256 issueDate);

    event AdminChanged(
        address indexed oldAdmin,
        address indexed newAdmin);

    function setUp() public {
        vm.prank(admin);
        issuance = new Issuance();
    }

    // Test constructor sets admin correctly
    function testConstructor() public view {
        assertEq(issuance.admin(), admin, "Admin should be set to deployer");
    }

    function testIssueCertificate() public {
        vm.prank(admin);
        vm.expectEmit(true, false, false, true);
        emit CertificateIssued(student1, 0, "Oche", "Math", block.timestamp);
        issuance.issueCertificate(student1, "CERT123", "Oche", "Math", 0);
        (string memory certId, string memory studentName, string memory course, uint256 issueDate, bool exists) = issuance.certificates(student1);
        assertTrue(exists, "Certificate should exist");
        assertEq(certId, "CERT123", "Certificate ID should match");
        assertEq(studentName, "Oche", "Student name should match");
        assertEq(course, "Math", "Course should match");
        assertEq(issueDate, block.timestamp, "Issue date should be current timestamp");
    }

    // Test issuing certificate to zero address
    function testIssueCertificateZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(Issuance.InvalidInput.selector);
        issuance.issueCertificate(address(0), "CERT123", "Oche", "Math", 0);
    }

    // Test issuing certificate with empty ID
    function testIssueCertificateEmptyId() public {
        vm.prank(admin);
        vm.expectRevert(Issuance.InvalidInput.selector);
        issuance.issueCertificate(student1, "", "Oche", "Math", 0);
    }

    // Test issuing certificate with empty name
    function testIssueCertificateEmptyName() public {
        vm.prank(admin);
        vm.expectRevert(Issuance.InvalidInput.selector);
        issuance.issueCertificate(student1, "CERT123", "", "Math", 0);
    }

    // Test issuing duplicate certificate
    function testIssueCertificateAlreadyExists() public {
        vm.prank(admin);
        issuance.issueCertificate(student1, "CERT123", "Oche", "Math", 0);
        vm.prank(admin);
        vm.expectRevert(Issuance.CertificateAlreadyExists.selector);
        issuance.issueCertificate(student1, "CERT124", "Oche", "Math", 0);
    }

    // Test non-admin cannot issue certificate
    function testIssueCertificateNonAdmin() public {
        vm.prank(nonAdmin);
        vm.expectRevert(Issuance.OnlyAdmin.selector);
        issuance.issueCertificate(student1, "CERT123", "Oche", "Math", 0);
    }
    
    // Test verifying a valid certificate
    function testVerifyCertificate() public {
        vm.prank(admin);
        issuance.issueCertificate(student1, "CERT123", "Oche", "Math", 0);
        (bool exists, string memory certId, string memory studentName, string memory course, uint256 issueDate) = issuance.verifyCertificate(student1);
        assertTrue(exists, "Certificate should exist");
        assertEq(certId, "CERT123", "Certificate ID should match");
        assertEq(studentName, "Oche", "Student name should match");
        assertEq(course, "Math", "Course should match");
        assertEq(issueDate, block.timestamp, "Issue date should match");
    }

    // Test verifying non-existent certificate
    function testVerifyCertificateNotFound() public {
        vm.expectRevert(Issuance.CertificateNotFound.selector);
        issuance.verifyCertificate(student1);
    }

    // Test transferring admin
    function testTransferAdmin() public {
        vm.prank(admin);
        vm.expectEmit(true, true, false, true);
        emit AdminChanged(admin, newAdmin);
        issuance.transferAdmin(newAdmin);
        assertEq(issuance.admin(), newAdmin, "Admin should be updated");
    }

}