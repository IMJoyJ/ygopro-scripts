--独法師
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤·特殊召唤。
-- ①：这张卡可以从手卡攻击表示特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的怪兽召唤·反转召唤·特殊召唤的场合发动。这张卡破坏。
function c263926.initial_effect(c)
	-- 效果原文：自己场上有怪兽存在的场合，这张卡不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c263926.sumcon)
	c:RegisterEffect(e1)
	-- 效果原文：自己场上有怪兽存在的场合，这张卡不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c263926.sumlimit)
	c:RegisterEffect(e2)
	-- 效果原文：①：这张卡可以从手卡攻击表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetTargetRange(POS_FACEUP_ATTACK,0)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c263926.sprcon)
	c:RegisterEffect(e3)
	-- 效果原文：②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的怪兽召唤·反转召唤·特殊召唤的场合发动。这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(263926,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c263926.descon)
	e4:SetTarget(c263926.destg)
	e4:SetOperation(c263926.desop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
-- 规则层面：判断自己场上有怪兽存在
function c263926.sumcon(e)
	-- 规则层面：获取己方场上怪兽数量，大于0则返回true
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)>0
end
-- 规则层面：设置特殊召唤条件
function c263926.sumlimit(e,se,sp,st,pos,tp)
	-- 规则层面：判断特殊召唤玩家场上没有怪兽
	return Duel.GetFieldGroupCount(sp,LOCATION_MZONE,0)==0
end
-- 规则层面：设置特殊召唤的条件
function c263926.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面：判断特殊召唤玩家场上没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 规则层面：判断特殊召唤玩家场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 规则层面：判断连锁触发时是否包含己方怪兽
function c263926.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 规则层面：设置破坏效果的目标和操作信息
function c263926.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 规则层面：设置破坏效果的处理对象为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 规则层面：执行破坏效果
function c263926.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面：以效果原因破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
