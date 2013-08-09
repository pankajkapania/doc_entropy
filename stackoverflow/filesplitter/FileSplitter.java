import java.io.*;
import java.util.Random;

public class FileSplitter{

	int postPerFile;
	int[] postCount = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	String ext = ".dat";

	public static void main(String args[]) {
		String folder = "data";
		String file = args[0];//"test.data";
		File SOFile = new File(folder + "/" + file);
		FileSplitter splitter = new FileSplitter();

		try {
			splitter.split(SOFile);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		splitter.printPostCountStatus();
	}

	private void printPostCountStatus() {
		for (int i = 0; i < 10; i++) {
			System.out.println(i + " : " + postCount[i]);
		}

	}

	private void split(File file) throws IOException {
		splitFile(file);
	}

	private void splitFile(File file) throws IOException {
		int postCount = countPosts(file);
		postPerFile = (int) Math.ceil((double) postCount / 10);
		System.out.println("Post Per File: " + postPerFile);
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(file));
			String post = null;
			int count = 0;
			while ((post = reader.readLine()) != null) {
				writePostToFile(post);
			}
		} finally{
			reader.close();
		}

	}

	private void writePostToFile(String post) throws IOException {
		int file = selectFileToWritePost();
		String folder = "splitted_files";//"test_spfiles";//
		File Splitted = new File(folder + "/" + file + ext);
		BufferedWriter out = null;
		try {
			out = new BufferedWriter(new FileWriter(Splitted,true));
			out.write(post+"\n");
		} finally{
			out.close();
		}
		postCount[file] = ++postCount[file];
	}

	private int selectFileToWritePost() {
		Random generator = new Random();
		int fileName = generator.nextInt(10);

		while ((postCount[fileName] > (postPerFile - 1))) {
			fileName = generator.nextInt(10);
		}

		return fileName;
	}

	private int countPosts(File file) throws IOException {
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(file));
			String line = null;
			int count = 0;
			while ((line = reader.readLine()) != null) {
				count++;
			}
			System.out.println("Post Count:" + count);
			return count;
		}finally{
			reader.close();
		}
	}

}
