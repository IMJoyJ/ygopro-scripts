--トゥーン・アンティーク・ギアゴーレム
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ④：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c7171149.initial_effect(c)
	-- 在卡片信息中注册其关联的卡片「卡通世界」的卡名密码
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c7171149.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c7171149.dircon)
	c:RegisterEffect(e4)
	-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(c7171149.aclimit)
	e5:SetCondition(c7171149.actcon)
	c:RegisterEffect(e5)
	-- ④：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e6)
end
-- 召唤、反转召唤、特殊召唤成功时触发的函数，用于给自身注册本回合不能攻击的效果
function c7171149.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「卡通世界」
function c7171149.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件：表侧表示的卡通怪兽
function c7171149.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断是否满足直接攻击的条件：自己场上有「卡通世界」且对方场上没有卡通怪兽
function c7171149.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c7171149.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否不存在表侧表示的卡通怪兽
		and not Duel.IsExistingMatchingCard(c7171149.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 限制发动的卡片类型过滤：魔法·陷阱卡的发动
function c7171149.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 魔法·陷阱卡发动限制的条件：这张卡进行攻击
function c7171149.actcon(e)
	-- 检查当前攻击的怪兽是否是这张卡自身
	return Duel.GetAttacker()==e:GetHandler()
end
