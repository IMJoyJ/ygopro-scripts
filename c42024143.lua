--XX－セイバー ガルドストライク
-- 效果：
-- 自己墓地有名字带有「X-剑士」的怪兽2只以上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c42024143.initial_effect(c)
	-- 自己墓地有名字带有「X-剑士」的怪兽2只以上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42024143.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否为名字带有「X-剑士」的怪兽卡（满足系列字段0x100d且是怪兽类型）。
function c42024143.spfilter(c)
	return c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤手续的条件判定：当c为nil时表示仅询问能否进行特殊召唤，返回true；否则需要自己场上主要怪兽区有空位、自己场上没有怪兽、且自己墓地存在至少2只符合条件的「X-剑士」怪兽。
function c42024143.spcon(e,c)
	if c==nil then return true end
	-- 作为特殊召唤条件之一：确认该卡的持有者（控制者）的主要怪兽区存在空位，保证能够特殊召唤上场。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 作为特殊召唤条件之一：确认该卡控制者场上没有怪兽（自己主要怪兽区的怪兽数量为0），满足“自己场上没有怪兽存在”的前提。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 作为特殊召唤条件之一：确认该卡控制者墓地存在至少2只满足spfilter条件的卡，即名字带有「X-剑士」的怪兽，满足“墓地有X-剑士怪兽2只以上”的要求。
		and Duel.IsExistingMatchingCard(c42024143.spfilter,c:GetControler(),LOCATION_GRAVE,0,2,nil)
end
