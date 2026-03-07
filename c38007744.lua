--先史遺産モアイキャリア
-- 效果：
-- 对方场上有卡存在，自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
function c38007744.initial_effect(c)
	-- 效果原文内容：对方场上有卡存在，自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38007744.spcon)
	c:RegisterEffect(e1)
end
-- 满足特殊召唤条件时的判断函数
function c38007744.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有卡存在
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
		-- 判断对方场上是否有卡存在
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)>0
		-- 判断自己主要怪兽区是否有空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
