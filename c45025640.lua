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
-- 伤害代受效果的适用条件：判断这张卡是否参与了本次战斗，只有本卡作为攻击怪兽或攻击对象时，其战斗伤害才由自己代受。
function c45025640.rfcon(e)
	-- 返回“攻击怪兽是这张卡”或“攻击对象是这张卡”的布尔值，即本卡确实参与了当前战斗。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- ②效果的发动条件：伤害步骤中本卡的持有者受到战斗伤害，且本卡参与了该次战斗，并且本卡没有被战斗破坏确定。
function c45025640.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==tp and bit.band(r,REASON_BATTLE)~=0
		-- 确认本次战斗的攻击怪兽或攻击对象就是这张卡，即该战斗伤害确实是由这张卡的战斗所产生的。
		and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果发动时的目标处理：没有选择对象，直接允许发动，并登记将本卡送回手卡的处理信息。
function c45025640.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁的效果处理类别为“加入手卡”，对象为本卡，数量为1，不指定玩家和区域。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果解决时的操作：将本卡从当前场所送回其持有者的手卡。
function c45025640.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以效果原因送回持有者手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
