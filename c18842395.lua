--パワー・インベーダー
-- 效果：
-- 对方场上有怪兽2只以上存在的场合，这张卡可以不用解放作召唤。
function c18842395.initial_effect(c)
	-- 效果原文内容：对方场上有怪兽2只以上存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18842395,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c18842395.ntcon)
	c:RegisterEffect(e1)
end
-- 判断召唤条件是否满足，包括等级、场地空位和对方怪兽数量
function c18842395.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查召唤时是否需要解放（不需要解放）且怪兽等级不低于5，且自身所在场地上有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上怪兽数量是否不少于2只
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>=2
end
