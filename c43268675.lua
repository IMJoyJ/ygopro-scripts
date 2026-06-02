--幻奏の音女オペラ
-- 效果：
-- ①：这张卡在召唤·反转的回合不能攻击。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。这个回合，自己场上的「幻奏」怪兽不会被战斗·效果破坏。
function c43268675.initial_effect(c)
	-- ①：这张卡在召唤·反转的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c43268675.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。这个回合，自己场上的「幻奏」怪兽不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c43268675.indcon)
	e3:SetOperation(c43268675.indop)
	c:RegisterEffect(e3)
end
-- 限制怪兽攻击的的激活函数，在对应事件触发时给自己注册不能攻击的效果
function c43268675.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在召唤·反转的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 作为融合素材送墓的效果发动条件函数，检查是否是因为融合召唤而送去墓地
function c43268675.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_FUSION and c:IsLocation(LOCATION_GRAVE) and not c:IsReason(REASON_RETURN)
end
-- 融合素材送墓效果的的激活函数，注册自己场上的「幻奏」怪兽在此回合内不会被战斗或效果破坏的效果
function c43268675.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的「幻奏」怪兽不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该破坏免疫效果的对象为自己场上的「幻奏」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将「幻奏」怪兽不会被战斗破坏的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 将「幻奏」怪兽不会被效果破坏的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
