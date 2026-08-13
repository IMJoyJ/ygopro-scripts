--紫毒の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己的魔法师族·暗属性怪兽进行战斗的伤害计算前才能发动。那只怪兽的攻击力直到那次伤害步骤结束时上升1200。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这张卡在规则上也当作「融合龙」卡使用。
-- ①：这张卡被战斗·效果破坏的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c48461764.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽的基本属性，使其能够进行灵摆召唤以及作为灵摆卡发动。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的魔法师族·暗属性怪兽进行战斗的伤害计算前才能发动。那只怪兽的攻击力直到那次伤害步骤结束时上升1200。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48461764,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCountLimit(1)
	e1:SetCondition(c48461764.atkcon)
	e1:SetTarget(c48461764.atktg)
	e1:SetOperation(c48461764.atkop)
	c:RegisterEffect(e1)
	-- ①：这张卡被战斗·效果破坏的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48461764,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c48461764.descon)
	e3:SetTarget(c48461764.destg)
	e3:SetOperation(c48461764.desop)
	c:RegisterEffect(e3)
end
-- 该函数为①效果的发动条件，判定进行战斗的怪兽中是否存在己方控制的暗属性魔法师族怪兽（攻击方或攻击对象均可）。
function c48461764.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		-- 若攻击怪兽不是自己控制的，则将判定对象改为攻击目标的怪兽。
		a=Duel.GetAttackTarget()
	end
	return a and a:IsAttribute(ATTRIBUTE_DARK) and a:IsRace(RACE_SPELLCASTER)
end
-- 该函数为①效果的发动目标检查，效果发动合法时不取对象，同时将“破坏这张卡”写入操作信息。
function c48461764.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将破坏发动效果的这张卡，用于连锁判定和效果处理预告。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 该函数为①效果的实际处理：使战斗的己方暗属性魔法师族怪兽攻击力上升1200直到伤害步骤结束，那之后破坏这张卡。
function c48461764.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前战斗的攻击怪兽作为攻击力提升对象。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是对方控制，则将效果对象改为攻击目标怪兽，以确保己方怪兽受到增益。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力直到那次伤害步骤结束时上升1200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 中断当前效果处理，将随后的『这张卡破坏』与之前的攻击力上升处理分为不同时点，以符合『那之后』的时序。
		Duel.BreakEffect()
		-- 以效果原因将这张卡（紫毒之魔术师）破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 该函数为②效果的发动条件，判定这张卡是因战斗或效果而被破坏。
function c48461764.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 该函数为②效果的发动目标检查与选择，需要以场上1张表侧表示的卡为对象。
function c48461764.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 效果发动时检查场上是否存在1张表侧表示的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家弹出选择提示，要求其选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示的卡作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将破坏所选的目标卡，用于连锁判定和效果处理预告。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 该函数为②效果的实际处理：若对象卡仍与效果相关，则将其破坏。
function c48461764.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
