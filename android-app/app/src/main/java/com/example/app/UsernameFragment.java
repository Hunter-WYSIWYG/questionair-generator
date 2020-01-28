package com.example.app;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import static com.example.app.MainActivity.username;

public class UsernameFragment extends Fragment {
	private TextView usernameTextView = null;

	@Override
	public View onCreateView (@NonNull final LayoutInflater inflater, @Nullable final ViewGroup container, @Nullable final Bundle savedInstanceState) {
		View result = inflater.inflate (R.layout.fragment_username, container, false);

		this.usernameTextView = result.findViewById (R.id.textViewUsername);
		this.usernameTextView.setText (getPreferenceValue (this.getActivity ()));

		Button changeUsername = result.findViewById(R.id.buttonChangeUsername);
		changeUsername.setOnClickListener(this::changeUsername);

		return result;
	}

	public void changeUsername (View changeUsername) {
		changeUsernameDialog (this.getActivity (), () -> {
			this.usernameTextView.setText (getPreferenceValue (this.getActivity ()));
		});
	}

	// get shared preference username
	public static String getPreferenceValue (Activity activity) {
		SharedPreferences sp = activity.getSharedPreferences (username, 0);
		String str = sp.getString ("key","Kein Benutzername erkannt.");
		return str;
	}
	public static void writeToPreference (String thePreference, Activity activity) {
		SharedPreferences.Editor editor = activity.getSharedPreferences(username,0).edit();
		editor.putString("key", thePreference);
		editor.commit();
	}

	public static void changeUsernameDialog (Activity activity) {
		changeUsernameDialog (activity, () -> {});
	}
	public static void changeUsernameDialog (Activity activity, Runnable callback) {
		AlertDialog.Builder alertDialog = new AlertDialog.Builder (activity);
		alertDialog.setTitle ("Benutzername");
		alertDialog.setMessage ("Bitte geben Sie den Benutzernamen ein.");
		EditText input = new EditText (activity);
		alertDialog.setView (input);
		alertDialog.setCancelable (true);
		alertDialog.setPositiveButton ("Ok", (dialog, id) -> {
			writeToPreference (input.getText ().toString (), activity);
			dialog.cancel ();
			callback.run ();
		});
		alertDialog.setNegativeButton ("Abbrechen", (dialog, id) -> dialog.cancel ());
		AlertDialog alert = alertDialog.create ();
		alert.show ();
	}
}