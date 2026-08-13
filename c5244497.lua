--スクープ・シューター
-- 效果：
-- 这张卡向持有比这张卡的攻击力高的守备力的场上表侧表示存在的怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
function c5244497.initial_effect(c)
	-- 这张卡向持有比这张卡的攻击力高的守备力的场上表侧表示存在的怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5244497,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c5244497.descon)
	e1:SetTarget(c5244497.destg)
	e1:SetOperation(c5244497.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：确认本卡为攻击者，且攻击对象是表侧表示、守备力高于本卡攻击力的怪兽时才满足条件。
function c5244497.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	-- 返回条件：本卡是攻击者，且攻击对象存在、表侧表示，并且攻击对象的守备力大于本卡的攻击力。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFaceup() and d:GetDefense()>e:GetHandler():GetAttack()
end
-- 效果发动时的目标处理：发动时无条件通过，并设置后续破坏效果的操作信息。
function c5244497.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的破坏操作信息：预定破坏的对象为当前攻击对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理时的执行操作：在效果处理时确认攻击对象仍与战斗相关且守备力仍高于本卡攻击力，则将那只怪兽破坏。
function c5244497.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:GetDefense()>e:GetHandler():GetAttack() then
		-- 以效果原因将攻击对象怪兽破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
