@edit @collections
Feature: Edit a EAD collection
  In order to manage a collection
  As a archivist
  I want to see & edit a collection's values


  Scenario: Visit Collection Edit Page
    Given I am logged in as "archivist1" 
    And I am on the edit document page for ead:fixture_ead_collection 
    Then I should see "Ead ID:" within "label"
    Then I should see an inline edit containing "american_colonial_currency"

  Scenario: Viewing browse/edit buttons
    Given I am logged in as "archivist1" 
    And I am on the edit document page for ead:fixture_ead_collection
    Then I should see a "span" tag with a "class" attribute of "edit-browse"

  Scenario: Viewing add child button
    Given I am logged in as "archivist1" 
    And I am on the edit document page for ead:fixture_ead_collection
    Then the "Child Type:" dropdown edit should contain "file" as an option
    And the "Child Type:" dropdown edit should contain "fonds" as an option
    And the "Child Type:" dropdown edit should contain "class" as an option
    And the "Child Type:" dropdown edit should contain "otherlevel" as an option
    And the "Child Type:" dropdown edit should contain "item" as an option
    And the "Child Type:" dropdown edit should contain "series" as an option
    And the "Child Type:" dropdown edit should contain "recordgrp" as an option
    And the "Child Type:" dropdown edit should contain "collection" as an option
    And the "Child Type:" dropdown edit should contain "subfonds" as an option
    And the "Child Type:" dropdown edit should contain "subseries" as an option