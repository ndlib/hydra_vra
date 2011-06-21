@show @collections
Feature: Show a EAD collection
  In order to view a collection
  As a scholar
  I want to see a collection's values
  
  Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for ead:fixture_ead_collection
    Then I should see "Ead ID: american_colonial_currency"
    And I should see "Title: Guide to the American Colonial Currency Collection "
    And I should see "Author: Louis Jordan "
    And I should see "Publisher: Department of Special Collections, Hesburgh Libraries of Notre Dame"
    And I should see "Publisher Address: 102 Hesburgh Library, Notre Dame, IN 46556" 
    And I should see "Published Date: October 2010"
    And I should see "Finding Aid Creator: Finding aid encoded in EAD, version 2002 by Tracy Bergstrom,2010" 
    And I should see "Finding Aid Creation Date: 2010" 
    And I should see "Langusage: Finding aid written inEnglish" 
    And I should see "Language: English" 
    And I should see "Unit Head: Collection Summary" 
    And I should see "Unit Title: American Colonial Currency Collection" 
    And I should see "Unit Id: COL" 
    And I should see "Unit Date: [bulk: 1700-1800]" 
    And I should see "Unit Language: Collection material in English and French."
    And I should see "Organization: University of Notre DameHesburgh Libraries, Department of Special Collections." 
    And I should see "Department: Hesburgh Libraries, Department of Special Collections." 
    And I should see "Organization Address: 102 Hesburgh Library, Notre Dame, IN 46556" 
    And I should see "Access Restriction Head: Restrictions" 
    And I should see "Access Restriction Info: There are no access restrictions on this collection.Restrictions" 
    And I should see "Acquisition Head: Acquisition and Processing Note" 
    And I should see "Acquisition Info: The Inquisition collection is described by Louis Jordan as materials are acquired.Acquisition and Processing Note"
    And I should see "Prefercite Info: Researchers wishing to cite this collection should include the following information: Department of Special Collections, Hesburgh Libraries of Notre Dame.Preferred Citation" 
    And I should not see a link to "the edit document page for ead_fixture_ead_collection"