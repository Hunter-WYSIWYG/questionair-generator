package com.example.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;

public class AlarmReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		notifynow (context,intent);
	}
	
	public void notifynow(Context context,Intent recintent) {
	//set intent for click
		Intent intent = new Intent(context, MainActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		PendingIntent pendingIntent = PendingIntent.getActivity(context,recintent.getIntExtra("remindernmb",-1), intent, PendingIntent.FLAG_UPDATE_CURRENT);
		
		//build notification preparation
		NotificationManager notificationManager = (NotificationManager) context.getSystemService (Context.NOTIFICATION_SERVICE);
		NotificationCompat.Builder builder;
		String channelId = "fragebogen";
		int currentApiVersion = android.os.Build.VERSION.SDK_INT;
		if (currentApiVersion > 25) {
			NotificationChannel notificationChannel = new NotificationChannel(channelId, "Notifications Channel", NotificationManager.IMPORTANCE_DEFAULT);
			notificationManager.createNotificationChannel(notificationChannel);
		}
		//build notification
					builder = new NotificationCompat.Builder (context, channelId);
					Notification notify = builder
							.setContentTitle("Es wartet " + recintent.getStringExtra("questionnaire") +" auf dich!")
							.setContentText(recintent.getStringExtra("reminder"))
							.setSmallIcon(R.drawable.smiley)
							.setContentIntent (pendingIntent)
							.build ();
					
					//send notification
					notificationManager.notify (0, notify);
				
	}
}