<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes"/>
	<xsl:template match="/">
		<html>
		<head>
                <h1 align="center"><a href="#"><xsl:value-of select="ead/eadheader/filedesc/titlestmt/titleproper"/></a></h1>
		<h2 class="section-title" style="position:relative;left:20px;"><a href="#">Collection Summary</a></h2>
		</head>
		<body>
			<xsl:for-each select="ead">
				<xsl:for-each select="eadheader">
<!--					<table width="100%">
					<tr><td width="25%" align="right">Ead ID: </td><td width="75%"><xsl:value-of select="eadid"/></td></tr>
					<xsl:if test="filedesc">
						<xsl:for-each select="filedesc">
							<xsl:for-each select="titlestmt">
								<tr><td width="25%" align="right">Title: </td><td width="75%"><xsl:value-of select="titleproper"/></td></tr> 
								<tr><td width="25%" align="right">Author: </td><td width="75%"><xsl:value-of select="author"/></td></tr>
							</xsl:for-each>
							<xsl:for-each select="publicationstmt">
								<tr><td width="25%" align="right">Publisher: </td><td width="75%"><xsl:value-of select="publisher"/></td></tr>
								<xsl:for-each select="address">
									<tr><td width="25%" align="right">Publisher Address: </td><td width="75%"><xsl:value-of select="addressline"/></td></tr>
								</xsl:for-each>
								<tr><td width="25%" align="right">Published Date: </td><td width="75%"><xsl:value-of select="date"/></td></tr>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="profiledesc">
						<xsl:for-each select="profiledesc">
							<xsl:for-each select="creation">
								<tr><td width="25%" align="right">Creator: </td><td width="75%"><xsl:value-of select="text()"/></td></tr>
								<tr><td width="25%" align="right">Creation Date: </td><td width="75%"><xsl:value-of select="date"/></td></tr>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:if>
					</table> -->
				</xsl:for-each>
				<xsl:for-each select="frontmatter">
<!--					<tr><td>Frontmatter Title: </td><td><xsl:value-of select="titlepage/titleproper"/></td></tr> -->
				</xsl:for-each>
				<xsl:for-each select="archdesc">
					<table width="100%" style="position:relative;left:20px;">
					<tr><td style="width:15%;color:#483D8B;" valign="top">Title: </td><td width="85%"><xsl:value-of select="did/unittitle"/></td></tr>
					<tr><td style="width:15%;color:#483D8B;" valign="top">Dates: </td><td width="85%"><xsl:value-of select="did/unitdate"/></td></tr>
					<tr><td style="width:15%;color:#483D8B;" valign="top">Identification: </td><td width="85%"><xsl:value-of select="did/unitid"/></td></tr>
					<tr><td style="width:15%;color:#483D8B;" valign="top">Language: </td><td width="85%"><xsl:value-of select="did/langmaterial/language"/></td></tr>
					<tr><td style="width:15%;color:#483D8B;" valign="top">Repository: </td><td width="85%"><xsl:value-of select="did/repository/corpname/text()"/> <xsl:value-of select="did/repository/corpname/subarea"/> <xsl:value-of select="did/repository/address/addressline"/></td></tr>
					</table>
					<h2  class="section-title" style="position:relative;left:20px;"><a href="#">Administrative Information</a></h2>
					<table  width="100%" style="position:relative;left:20px;">
						<tr><td style="width:30%;color:#483D8B;" valign="top">Restrictions: </td><td><xsl:value-of select="accessrestrict/text()"/></td></tr>
						<tr><td style="width:30%;color:#483D8B;" valign="top">Preferred Citation: </td><td><xsl:value-of select="prefercite/text()"/></td></tr>
						<tr><td style="width:30%;color:#483D8B;" valign="top">Acquisition and Processing Note: </td><td><xsl:value-of select="acqinfo/text()"/></td></tr>
					</table>
					<h2  class="section-title" style="position:relative;left:20px;"><a href="#">Container List</a></h2>
					<ul style="position:relative;left:20px;">
					<xsl:for-each select="dsc/c01">
						<li><xsl:value-of select="did/unitid"/>. 
						<xsl:if test="did/origination">
							<xsl:for-each select="did/origination/persname">
								<xsl:value-of select="."/>. 
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="did/unittitle">
							<xsl:for-each select="did/unittitle">
								<xsl:value-of select="./text()"/>. 
								<xsl:value-of select="unitdate"/>. 
								<xsl:value-of select="imprint/geogname"/>. 
								<xsl:value-of select="imprint/publisher"/>. 
							</xsl:for-each>							
						</xsl:if>
<!--						<xsl:value-of select="scopecontent"/> -->
						<xsl:value-of select="controlaccess/genreform"/>
						<br/>
						<ul>
						<xsl:for-each select="c02">
							<li><xsl:value-of select="did/unitid"/>. 
							<xsl:if test="did/origination">
								<xsl:for-each select="did/origination/persname">
									<xsl:value-of select="."/>. 
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="did/unittitle">
								<xsl:for-each select="did/unittitle">. 
									<xsl:value-of select="text()"/>. 
									<xsl:value-of select="num"/>. 
								</xsl:for-each>							
							</xsl:if>
							<xsl:value-of select="did/physdesc/dimensions"/>. 
<!--							<xsl:value-of select="scopecontent"/>. -->
							<xsl:value-of select="odd"/>. 
							<xsl:value-of select="controlaccess/genreform"/>. 
							<xsl:value-of select="acqinfo"/></li>
							<br/>
						</xsl:for-each>
						</ul>
						</li>
					</xsl:for-each>
					</ul>
				</xsl:for-each>
			</xsl:for-each>
		</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
