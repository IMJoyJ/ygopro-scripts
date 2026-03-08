--XX－セイバー ガルドストライク
-- 效果：
-- 自己墓地有名字带有「X-剑士」的怪兽2只以上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c42024143.initial_effect(c)
	-- 效果原文内容：自己墓地有名字带有「X-剑士」的怪兽2只以上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42024143.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：墓地里名字带有「X-剑士」的怪兽
function c42024143.spfilter(c)
	return c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER)
end
-- 判断特殊召唤条件是否满足：场上怪兽数量为0且手卡有2只以上名字带有「X-剑士」的怪兽
function c42024143.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否没有怪兽存在
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断自己墓地是否存在至少2张名字带有「X-剑士」的怪兽卡
		and Duel.IsExistingMatchingCard(c42024143.spfilter,c:GetControler(),LOCATION_GRAVE,0,2,nil)
end
