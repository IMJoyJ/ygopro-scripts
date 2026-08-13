--疾風の暗黒騎士ガイア
-- 效果：
-- ①：手卡只有这1张卡的场合，这张卡可以不用解放作召唤。
function c16589042.initial_effect(c)
	-- ①：手卡只有这1张卡的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16589042,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c16589042.ntcon)
	c:RegisterEffect(e1)
end
-- 召唤规则效果的条件函数：当c为nil时表示存在可尝试的召唤方式；否则需满足无需解放、此卡等级5以上、我方手牌只有此卡且主要怪兽区有空位。
function c16589042.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定无需解放（minc==0）、此卡等级为5以上、并且我方手牌只有这1张卡。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)==1
		-- 判定我方主要怪兽区存在可用的空格，以确认能够通常召唤此卡。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
