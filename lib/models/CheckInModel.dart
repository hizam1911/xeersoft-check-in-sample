class CheckInModel {
  static String table = 'checkins';
  static String columnCheckInId = 'checkin_id';
  static String columnUserId = 'user_id';
  static String columnCheckInDateTime = 'checkin_date_time';
  static String columnCheckInStatus = 'checkin_status';
  static String columnCreatedAt = 'created_at';
  static String columnModifiedAt = 'modified_at';

  final int? checkInId;
  final int userId;
  final String? checkInDateTime;
  final bool checkInStatus;
  final String? createdAt;
  final String? modifiedAt;

  CheckInModel({
    this.checkInId,
    this.userId = 0,
    this.checkInDateTime,
    this.checkInStatus = false,
    this.createdAt,
    this.modifiedAt,
  });

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      columnUserId: userId,
      columnCheckInStatus: checkInStatus ? 1 : 0,
    };

    if (checkInId != null) {
      map[columnCheckInId] = checkInId;
    }

    if (checkInDateTime != null) {
      map[columnCheckInDateTime] = checkInDateTime;
    }

    if (createdAt != null) {
      map[columnCreatedAt] = createdAt;
    }

    if (modifiedAt != null) {
      map[columnModifiedAt] = modifiedAt;
    }

    return map;
  }

  factory CheckInModel.fromMap(Map<String, dynamic> map) {
    return CheckInModel(
      checkInId: map[columnCheckInId],
      userId: map[columnUserId],
      checkInDateTime: map[columnCheckInDateTime],
      checkInStatus: map[columnCheckInStatus] == 1,
      createdAt: map[columnCreatedAt],
      modifiedAt: map[columnModifiedAt],
    );
  }
}