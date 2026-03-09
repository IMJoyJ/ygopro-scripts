--紫毒の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己的魔法师族·暗属性怪兽进行战斗的伤害计算前才能发动。那只怪兽的攻击力直到那次伤害步骤结束时上升1200。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这张卡在规则上也当作「融合龙」卡使用。
-- ①：这张卡被战斗·效果破坏的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c48461764.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 判断是否满足效果发动条件：攻击怪兽是否为我方控制且属性为暗、种族为魔法师族
function c48461764.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		-- 若攻击怪兽不是我方控制，则获取防守怪兽作为攻击目标
		a=Duel.GetAttackTarget()
	end
	return a and a:IsAttribute(ATTRIBUTE_DARK) and a:IsRace(RACE_SPELLCASTER)
end
-- 设置效果处理时的操作信息，包括将自身送去破坏
function c48461764.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该卡送去破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行效果处理：提升攻击怪兽攻击力并破坏自身
function c48461764.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是我方控制，则获取防守怪兽作为攻击目标
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		-- 创建一个改变攻击力的效果，使目标怪兽攻击力上升1200点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 中断当前效果处理，防止连锁错时
		Duel.BreakEffect()
		-- 将自身破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 判断该卡是否因战斗或效果被破坏
function c48461764.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 设置选择破坏对象的效果处理信息
function c48461764.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检查是否存在满足条件的场上表侧表示卡作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一个场上表侧表示的卡作为破坏目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选中的卡送去破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果处理：破坏所选目标卡
function c48461764.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
