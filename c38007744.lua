--先史遺産モアイキャリア
-- 效果：
-- 对方场上有卡存在，自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
function c38007744.initial_effect(c)
	-- 对方场上有卡存在，自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38007744.spcon)
	c:RegisterEffect(e1)
end
-- 该函数是特殊召唤规则效果的手牌特殊召唤条件判定：若c为空则默认允许；否则需满足自己场上无卡、对方场上有卡且自己主要怪兽区有空位才能从手卡特殊召唤。
function c38007744.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上没有任何卡（包括怪兽区和魔法陷阱区），满足“自己场上没有卡存在”的条件。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
		-- 检查对方场上有卡存在（包括怪兽区和魔法陷阱区），满足“对方场上有卡存在”的条件。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)>0
		-- 检查自己场上的主要怪兽区存在可用空格，确保特殊召唤时有空位可放置该怪兽。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
