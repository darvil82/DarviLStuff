import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;

/**
 * File iterable which, when iterated over, will return an {@link EnumeratedItem} with
 * each line and index pair.
 *
 * When the iteration starts, the {@link BufferedReader} in use is closed automatically.
 */
public class OpenFile implements Iterable<EnumeratedItem<String>> {
	public final BufferedReader br;

	/**
	 * Open a file with a given charset.
	 * @param filename the file name
	 * @param charset the charset
	 * @throws FileNotFoundException if the file is not found
	 */
	public OpenFile(String filename, Charset charset) throws FileNotFoundException {
		br = new BufferedReader(
			new InputStreamReader(
				new FileInputStream(filename),
				charset
			)
		);
	}

	/**
	 * Open a file with the default charset (UTF-8).
	 * @param filename the file name
	 * @throws FileNotFoundException if the file is not found
	 */
	public OpenFile(String filename) throws FileNotFoundException {
		this(filename, StandardCharsets.UTF_8);
	}

	/**
	 * Open a file with a given buffered reader.
	 * @param br the buffered reader
	 */
	public OpenFile(BufferedReader br) {
		this.br = br;
	}

	@Override
	public FileIterator iterator() {
		return new FileIterator(this);
	}

	// We don't want to give warnings to the user about closing the file.
	// This is why Closeable is not being implemented.
	public void close() throws IOException {
		br.close();
	}
}


class FileIterator implements Iterator<EnumeratedItem<String>> {
	protected final String[] lines;
	protected int currentLine;

	public FileIterator(OpenFile fi) {
		lines = fi.br.lines().toArray(String[]::new);
		try {
			fi.br.close();
		} catch (IOException e) {
			// already closed?
		}
	}

	@Override
	public boolean hasNext() {
		return lines.length >= currentLine + 1;
	}

	@Override
	public EnumeratedItem<String> next() {
		return new EnumeratedItem<>(lines[currentLine], currentLine++);
	}
}


record EnumeratedItem<T>(T item, int index) {
	public String toString() {
		return index + ": " + item;
	}
}