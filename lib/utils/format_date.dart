String formatLastSeen(String lastSeenString) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(lastSeenString));
  Duration difference = DateTime.now().difference(dateTime);

  if (difference.inDays >= 7) {
    return formatDate(dateTime);
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'just now';
  }
}
String formatDate(DateTime dateTime) {
  return '${dateTime.day} ${getMonth(dateTime.month)} ${dateTime.year}';
}

String getMonth(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}
