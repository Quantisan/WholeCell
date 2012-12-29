import chemaxon.marvin.MolPrinter;
import chemaxon.struc.Molecule;
import chemaxon.formats.MolImporter;
import java.awt.Color;
import java.awt.Rectangle;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

public class DrawMolecule {
    static BufferedImage createTestImage(String smiles, int width, int height, Color bgColor) throws IOException {
        // Create a molecule
        Molecule mol = MolImporter.importMol(smiles);
		
        // Create a writable image
		Rectangle rect = new Rectangle(10, 10, width-20, height-20);
        BufferedImage im = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = im.createGraphics();		
		
        // Clear background
        g.setColor(bgColor);
        g.fillRect(0, 0, width, height);
		
        // Paint the molecule
        MolPrinter molPrinter = new MolPrinter(mol);
        molPrinter.setScale(molPrinter.maxScale(rect)); // fit image in the rectangle
        molPrinter.setBackgroundColor(bgColor);
        molPrinter.paint(g, rect);
        return im;
    }
    public static void main(String[] args) throws Exception {
		String smiles=args[0];
		int width=Integer.decode(args[1]);
		int height=Integer.decode(args[2]);
		Color bgColor=new Color(Integer.decode(args[3]), Integer.decode(args[4]), Integer.decode(args[5]));
		String format=args[6];
		String file=args[7];		
		
        BufferedImage im = createTestImage(smiles, width, height, bgColor);
        ImageIO.write(im, format, new File(file));
    }
}