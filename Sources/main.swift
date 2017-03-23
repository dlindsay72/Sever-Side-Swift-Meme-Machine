import Foundation
import HeliumLogger
import Kitura
import KituraStencil
import LoggerAPI
import SwiftGD

HeliumLogger.use()
let router = Router()

router.setDefault(templateEngine: StencilTemplateEngine())
router.post("/", middleware: BodyParser())
router.all("/static", middleware: StaticFileServer())

let rootDirectory = URL(fileURLWithPath: "\(FileManager().currentDirectoryPath)/public/uploads")
let originalsDirectory = rootDirectory.appendingPathComponent("originals")
let thumbsDirectory = rootDirectory.appendingPathComponent("thumbs")

router.get("/") {
  request, response, next in
  defer { next() }

  let fm = FileManager()
  guard let files = try? fm.contentsOfDirectory(at: originalsDirectory ,includingPropertiesForKeys: nil) else {
    return
  }

  let allFilenames = files.map { $0.lastPathComponent }
  let visibleFilenames = allFilenames.filter { !$0.hasPrefix(".") }

  try response.render("home", context: ["files": visibleFilenames])
}



Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
