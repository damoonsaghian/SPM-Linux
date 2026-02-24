// if there is a saved session file for the project, restore it

// ".cache/codev/notif-*" files: notifications

/*
class Project {
	pull() {
		// ushare pull
		// show a three'way diff, based on the main branch, pristine, and the working directory
		// then the user will be asked to accept all or some parts of the diff
	}
	
	pullRequest() {
		// ushare pullreq
	}
	
	pullRequestRetrieve(pristineUri, wdirUri) {
		// `ushare pullret ${pristineUri} ${wdirUri}`
	}
	
	pullRequestAnswer(pristineUri, branchUri) {
		// this will be run by the main developer
		// make a diff based on the sent pristine and branch, plus our own working directory	
		
		// pull requests can be kept to trace backdoors found later, back to the origin author
	}
	
	publish(gnNamespace, projectName) {
		// gnPublish
	}
	
	publishPackage() {
		// spm publish
	}
}
*/

/*
class ProjectView {
	dir: String,
	widget: Overlay, // floating layer can be used to view web'pages, images and videos
	mainView: ListBox,
	files: Files,
	centerView: Stack
	
	new(dirPath) {
		self.dirPath = dirPath;
		self.widget: Overlay = new Overlay();
		let mainBox = new Box(orient: HORIZONTAL);
		widget.setChild(mainBox);
		
		self.files = new Files();
		mainBox.append(files);
		
		self.centerView = new Stack();
		mainBox.append(centerView);
	}
}
*/
