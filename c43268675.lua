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
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c43268675.indcon)
	e3:SetOperation(c43268675.indop)
	c:RegisterEffect(e3)
end
-- 将该卡在召唤或反转时设置一个不能攻击的效果
function c43268675.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 使该卡在本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断是否为融合召唤的素材并进入墓地
function c43268675.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 使自己场上「幻奏」怪兽不会被战斗·效果破坏
function c43268675.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个使「幻奏」怪兽不会被战斗破坏的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置目标为「幻奏」卡组
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
