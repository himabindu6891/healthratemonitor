// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Health Rate Monitor
 * @dev Smart contract for storing and monitoring health metrics
 * @author Health Rate Monitor Team
 */
contract Project {
    
    // Struct to store health data
    struct HealthRecord {
        uint256 heartRate;        // beats per minute
        uint256 bloodPressureSys; // systolic pressure
        uint256 bloodPressureDia; // diastolic pressure
        uint256 oxygenLevel;      // oxygen saturation percentage
        uint256 timestamp;        // when the record was created
        bool isActive;            // record status
    }
    
    // Mapping from user address to their health records
    mapping(address => HealthRecord[]) private userHealthRecords;
    
    // Mapping to track authorized healthcare providers
    mapping(address => bool) public authorizedProviders;
    
    // Contract owner
    address public owner;
    
    // Events
    event HealthRecordAdded(address indexed user, uint256 timestamp);
    event ProviderAuthorized(address indexed provider);
    event ProviderRevoked(address indexed provider);
    event EmergencyAlert(address indexed user, string alertType);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAuthorizedProvider() {
        require(authorizedProviders[msg.sender] || msg.sender == owner, "Not authorized to add health records");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedProviders[msg.sender] = true;
    }
    
    /**
     * @dev Core Function 1: Add health record for a user
     * @param _user User's address
     * @param _heartRate Heart rate in BPM
     * @param _bloodPressureSys Systolic blood pressure
     * @param _bloodPressureDia Diastolic blood pressure
     * @param _oxygenLevel Oxygen saturation level
     */
    function addHealthRecord(
        address _user,
        uint256 _heartRate,
        uint256 _bloodPressureSys,
        uint256 _bloodPressureDia,
        uint256 _oxygenLevel
    ) external onlyAuthorizedProvider {
        require(_user != address(0), "Invalid user address");
        require(_heartRate > 0 && _heartRate <= 300, "Invalid heart rate");
        require(_bloodPressureSys > 0 && _bloodPressureSys <= 300, "Invalid systolic pressure");
        require(_bloodPressureDia > 0 && _bloodPressureDia <= 200, "Invalid diastolic pressure");
        require(_oxygenLevel > 0 && _oxygenLevel <= 100, "Invalid oxygen level");
        
        HealthRecord memory newRecord = HealthRecord({
            heartRate: _heartRate,
            bloodPressureSys: _bloodPressureSys,
            bloodPressureDia: _bloodPressureDia,
            oxygenLevel: _oxygenLevel,
            timestamp: block.timestamp,
            isActive: true
        });
        
        userHealthRecords[_user].push(newRecord);
        
        // Check for emergency conditions
        _checkEmergencyConditions(_user, newRecord);
        
        emit HealthRecordAdded(_user, block.timestamp);
    }
    
    /**
     * @dev Core Function 2: Get user's health records
     * @param _user User's address
     * @return Array of health records for the user
     */
    function getHealthRecords(address _user) external view returns (HealthRecord[] memory) {
        require(_user == msg.sender || authorizedProviders[msg.sender] || msg.sender == owner, 
                "Not authorized to view these records");
        return userHealthRecords[_user];
    }
    
    /**
     * @dev Core Function 3: Get latest health metrics for a user
     * @param _user User's address
     * @return Latest health record data
     */
    function getLatestHealthMetrics(address _user) external view returns (
        uint256 heartRate,
        uint256 bloodPressureSys,
        uint256 bloodPressureDia,
        uint256 oxygenLevel,
        uint256 timestamp
    ) {
        require(_user == msg.sender || authorizedProviders[msg.sender] || msg.sender == owner, 
                "Not authorized to view these records");
        require(userHealthRecords[_user].length > 0, "No health records found");
        
        HealthRecord memory latestRecord = userHealthRecords[_user][userHealthRecords[_user].length - 1];
        
        return (
            latestRecord.heartRate,
            latestRecord.bloodPressureSys,
            latestRecord.bloodPressureDia,
            latestRecord.oxygenLevel,
            latestRecord.timestamp
        );
    }
    
    /**
     * @dev Authorize healthcare provider
     * @param _provider Provider's address
     */
    function authorizeProvider(address _provider) external onlyOwner {
        require(_provider != address(0), "Invalid provider address");
        authorizedProviders[_provider] = true;
        emit ProviderAuthorized(_provider);
    }
    
    /**
     * @dev Revoke healthcare provider authorization
     * @param _provider Provider's address
     */
    function revokeProvider(address _provider) external onlyOwner {
        require(_provider != address(0), "Invalid provider address");
        authorizedProviders[_provider] = false;
        emit ProviderRevoked(_provider);
    }
    
    /**
     * @dev Get total number of records for a user
     * @param _user User's address
     * @return Number of health records
     */
    function getRecordCount(address _user) external view returns (uint256) {
        require(_user == msg.sender || authorizedProviders[msg.sender] || msg.sender == owner, 
                "Not authorized to view this information");
        return userHealthRecords[_user].length;
    }
    
    /**
     * @dev Internal function to check for emergency health conditions
     * @param _user User's address
     * @param _record Health record to check
     */
    function _checkEmergencyConditions(address _user, HealthRecord memory _record) internal {
        // Check for critical heart rate
        if (_record.heartRate < 50 || _record.heartRate > 120) {
            emit EmergencyAlert(_user, "Critical Heart Rate");
        }
        
        // Check for critical blood pressure
        if (_record.bloodPressureSys > 180 || _record.bloodPressureDia > 110) {
            emit EmergencyAlert(_user, "Critical Blood Pressure");
        }
        
        // Check for low oxygen levels
        if (_record.oxygenLevel < 90) {
            emit EmergencyAlert(_user, "Low Oxygen Level");
        }
    }
}
