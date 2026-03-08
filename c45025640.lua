--ボイコットン
-- 效果：
-- ①：这张卡的战斗发生的对对方的战斗伤害由自己代受。
-- ②：这张卡的战斗不让这张卡被破坏，让自己受到战斗伤害的场合发动。这张卡回到持有者手卡。
function c45025640.initial_effect(c)
	-- ①：这张卡的战斗发生的对对方的战斗伤害由自己代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c45025640.rfcon)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗不让这张卡被破坏，让自己受到战斗伤害的场合发动。这张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c45025640.thcon)
	e2:SetTarget(c45025640.thtg)
	e2:SetOperation(c45025640.thop)
	c:RegisterEffect(e2)
end
-- 判断是否为攻击或被攻击状态
function c45025640.rfcon(e)
	-- 判断是否为攻击或被攻击状态
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 伤害发动时的触发条件
function c45025640.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==tp and bit.band(r,REASON_BATTLE)~=0
		-- 判断是否为攻击或被攻击状态
		and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置效果发动时的目标
function c45025640.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该卡送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理函数
function c45025640.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡送回持有者手牌
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
