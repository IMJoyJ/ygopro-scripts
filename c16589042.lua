--疾風の暗黒騎士ガイア
-- 效果：
-- ①：手卡只有这1张卡的场合，这张卡可以不用解放作召唤。
function c16589042.initial_effect(c)
	-- 效果原文内容：①：手卡只有这1张卡的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16589042,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c16589042.ntcon)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断召唤条件是否满足，包括等级、手卡数量和场上空位
function c16589042.ntcon(e,c,minc)
	if c==nil then return true end
	-- 规则层面操作：检查召唤时是否满足等级不低于5且手卡只有这张卡
	return minc==0 and c:IsLevelAbove(5) and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)==1
		-- 规则层面操作：检查召唤时场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
