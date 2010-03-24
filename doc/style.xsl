<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<xsl:template name="collab.setup">
  <xsl:text>\renewcommand{\DBKindexation}{\begin{DBKindtable}&#10;</xsl:text>
  <xsl:apply-templates select=".//othercredit" mode="collab"/>
  <xsl:text>\end{DBKindtable}}&#10;</xsl:text>
</xsl:template>

<xsl:template match="othercredit" mode="collab">
  <xsl:text>\DBKinditem{</xsl:text>
  <xsl:value-of select="contrib"/>
  <xsl:text>}{</xsl:text>
  <xsl:apply-templates select="othername"/>
  <xsl:text>}{</xsl:text>
  <xsl:apply-templates select="firstname"/>
  <xsl:text> </xsl:text>
  <xsl:apply-templates select="surname"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="appendix[@id='appendix.rev']">
  <xsl:text>\chapter{\DBKrevhistorychapter}\begin{sffamily}\DBKrevhistory\end{sffamily}</xsl:text>
  <xsl:call-template name="label.id"/>
</xsl:template>

</xsl:stylesheet>

