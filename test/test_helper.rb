ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'FractalComposer.jar'
require 'simple-xml-1.7.2.jar'
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.util.FileHelper

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def fillin_generated_piece_values(piece = nil)
    piece ||= GeneratedPiece.new
    FileHelper.createAndUseTempFile 'test', 'mid', proc {|filename|      
        fp = FractalPiece.new
        fp.setGermString('G4 A4')
        fp.createDefaultSettings       
        fp.createPieceResultOutputManager.saveMidiFile(filename)
        
        piece.user_ip_address = '127.0.0.1'
        piece.fractal_piece = fp.getXmlRepresentation
        piece.generated_midi_file = filename
        
        yield piece
    }
  end
end
