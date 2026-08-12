--トゥーン・サイバー・ドラゴン
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ③：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
function c83629030.initial_effect(c)
	-- 在卡片中注册记载了「卡通世界」的卡片密码
	aux.AddCodeList(c,15259703)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c83629030.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c83629030.atklimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c83629030.dircon)
	c:RegisterEffect(e5)
end
-- 特殊召唤规则的条件判断函数：自己场上无怪兽、对方场上有怪兽，且自己场上有可用怪兽区域
function c83629030.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤·反转召唤·特殊召唤成功时执行的函数，为自身注册该回合不能攻击的效果
function c83629030.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示存在的「卡通世界」
function c83629030.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件：场上表侧表示存在的卡通怪兽
function c83629030.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击效果的条件判断：自己场上有「卡通世界」存在，且对方场上没有卡通怪兽存在
function c83629030.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c83629030.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否不存在表侧表示的卡通怪兽
		and not Duel.IsExistingMatchingCard(c83629030.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
