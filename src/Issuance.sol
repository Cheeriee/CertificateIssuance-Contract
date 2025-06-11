// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Issuance{
    address public admin;

    struct Certificate{ //struct to store candidate details
        string certificateId;
        string studentName;
        string course;
        uint256 issueDate;
        bool exists;
    }

    error OnlyAdmin();
    error InvalidInput();
    error CertificateNotFound();
    error CertificateAlreadyExists();

    event CertificateIssued(
        address indexed student, 
        string certificateId, 
        string studentName, 
        string course, 
        uint256 issueDate);

    event AdminChanged(
        address indexed oldAdmin,
        address indexed newAdmin);

    mapping(address == Certificate) public certificates;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        if(msg.sender != Admin) {
            revert OnlyAdmin();
        }
        _;
    }

    function issueCertificate( //function issues a certificate to a student
        address student
        string memory certificateId, 
        string memory course,
        uint256 issueDate,
            ) external onlyAdmin {
            if(student == address(0)) {
                revert InvalidInput();
            }
            if(bytes(certificateId).length == 0) {
                revert InvalidInput();
            }
            if(bytes(studentName).length == 0) {
                revert InvalidInput();
            }
            if(certificates[student].exists) { //check if certificate already exists for the student
                revert CertificateAlreadyExists();
            }
            
            certificates[student] = Certificate({
                certificateId: certificateId,
                studentName: studentName,
                course: course,
                issueDate: block.timestamp,
                exists: true
            })

            emit CertificateIssued(student, certificateId, studentName, course, block.timestamp);
        }
    function verifyCertificate(address student) external view returns(
        bool exists, 
        string memory certificateId, 
        string memory course, string memory studentName, 
        uint256 issueDate) {
            Certificate memory cert = certificates[student];
            if(!cert.exists) {
                revert CertificateNotFound();
            }

            return(
                cert.exists, 
                cert.certificateId, 
                cert.studentName, 
                cert.course, 
                cert.issueDate);       
}

    function transferAdmin(address newAdmin) external onlyAdmin{
        if(newAdmin == address(0)) {
            revert InvalidInput();
        }

        address oldAdmin = admin;
        admin = newAdmin;

        emit AdminChanged(oldAdmin, newAdmin);
    }
}