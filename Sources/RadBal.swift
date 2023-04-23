@main
public struct RadBal {
	public static func main() async throws {
		print("main started, sleeping")
		try await Task.sleep(for: .seconds(1))
		print("woke up, done!")
	}
}
