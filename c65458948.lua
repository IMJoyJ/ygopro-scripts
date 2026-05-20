--トゥーン・マーメイド
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的场合可以特殊召唤。
-- ①：这张卡在特殊召唤的回合不能攻击。
-- ②：这张卡若不支付500基本分则不能攻击宣言。
-- ③：对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。存在的场合，必须把卡通怪兽作为攻击对象。
-- ④：场上的「卡通世界」被破坏时这张卡破坏。
function c65458948.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果文本中记载了「卡通世界」
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c65458948.spcon)
	c:RegisterEffect(e2)
	-- ④：场上的「卡通世界」被破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c65458948.sdescon)
	e3:SetOperation(c65458948.sdesop)
	c:RegisterEffect(e3)
	-- ③：对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c65458948.dircon)
	c:RegisterEffect(e4)
	-- 存在的场合，必须把卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c65458948.atcon)
	e5:SetValue(c65458948.atlimit)
	c:RegisterEffect(e5)
	-- 存在的场合，必须把卡通怪兽作为攻击对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c65458948.atcon)
	c:RegisterEffect(e6)
	-- ①：这张卡在特殊召唤的回合不能攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c65458948.atklimit)
	c:RegisterEffect(e7)
	-- ②：这张卡若不支付500基本分则不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_COST)
	e8:SetCost(c65458948.atcost)
	e8:SetOperation(c65458948.atop)
	c:RegisterEffect(e8)
end
-- 过滤条件：场上表侧表示的「卡通世界」
function c65458948.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 特殊召唤规则的条件：怪兽区域有空位，且自己场上有表侧表示的「卡通世界」存在
function c65458948.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「卡通世界」
		and Duel.IsExistingMatchingCard(c65458948.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：因破坏而离场的表侧表示「卡通世界」
function c65458948.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 自毁效果的触发条件：离场的卡片中存在被破坏的表侧表示「卡通世界」
function c65458948.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65458948.sfilter,1,nil)
end
-- 自毁效果的操作：破坏自身
function c65458948.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤条件：对方场上表侧表示的卡通怪兽
function c65458948.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的条件：对方场上没有表侧表示的卡通怪兽
function c65458948.dircon(e)
	-- 检查对方场上是否不存在表侧表示的卡通怪兽
	return not Duel.IsExistingMatchingCard(c65458948.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 攻击限制的条件：对方场上有表侧表示的卡通怪兽存在
function c65458948.atcon(e)
	-- 检查对方场上是否存在表侧表示的卡通怪兽
	return Duel.IsExistingMatchingCard(c65458948.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 攻击目标限制：不能选择非卡通怪兽或里侧表示怪兽作为攻击对象
function c65458948.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 特殊召唤成功时的操作：给自身添加本回合不能攻击的效果
function c65458948.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 攻击宣言代价的检查：检查玩家是否能支付500基本分
function c65458948.atcost(e,c,tp)
	-- 检查攻击宣言玩家是否能支付500基本分
	return Duel.CheckLPCost(tp,500)
end
-- 攻击宣言代价的支付：支付500基本分
function c65458948.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除攻击宣言玩家500基本分
	Duel.PayLPCost(tp,500)
end
