--EMオッドアイズ・ミノタウロス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：自己的「娱乐伙伴」怪兽或者「异色眼」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽效果】
-- ①：自己的灵摆怪兽向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己场上的「娱乐伙伴」卡以及「异色眼」卡数量×100。
function c10731333.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	-- ←6 【灵摆】 6→ ①：自己的「娱乐伙伴」怪兽或者「异色眼」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c10731333.ptg)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：自己的灵摆怪兽向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己场上的「娱乐伙伴」卡以及「异色眼」卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c10731333.atkcon)
	e2:SetOperation(c10731333.atkop)
	c:RegisterEffect(e2)
end
-- 贯穿效果的对象过滤：判定攻击怪兽是否为持有「娱乐伙伴（0x9f）」或「异色眼（0x99）」字段的卡，仅此类怪兽能享受贯穿伤害。
function c10731333.ptg(e,c)
	return c:IsSetCard(0x9f,0x99)
end
-- 过滤出我方场上表侧表示且持有「娱乐伙伴（0x9f）」或「异色眼（0x99）」字段的卡，用于计算数量。
function c10731333.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99)
end
-- 效果发动条件：我方灵摆怪兽攻击对方表侧怪兽，且我方场上有表侧的「娱乐伙伴」或「异色眼」卡，且在伤害计算时才能发动。
function c10731333.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行伤害计算的攻击怪兽。
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	-- 统计我方场上表侧表示且持有「娱乐伙伴（0x9f）」或「异色眼（0x99）」字段的卡的数量，作为攻击力下降的数值依据。
	local gc=Duel.GetMatchingGroupCount(c10731333.atkfilter,tp,LOCATION_ONFIELD,0,nil)
	return a:IsControler(tp) and a:IsType(TYPE_PENDULUM) and d
		and d:IsFaceup() and not d:IsControler(tp) and gc>0
end
-- 效果处理：获取攻击对象的战斗目标，重新统计我方场上符合条件的字段卡数量；若对方怪兽仍与本次战斗相关且表侧表示，则使其攻击力仅在这次伤害计算时下降字段卡数量×100。
function c10731333.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽正在战斗的对方怪兽。
	local d=Duel.GetAttacker():GetBattleTarget()
	-- 统计我方场上表侧表示且持有「娱乐伙伴（0x9f）」或「异色眼（0x99）」字段的卡的数量，用于计算下降值。
	local gc=Duel.GetMatchingGroupCount(c10731333.atkfilter,tp,LOCATION_ONFIELD,0,nil)
	if d:IsRelateToBattle() and d:IsFaceup() then
		-- 那只对方怪兽的攻击力只在那次伤害计算时下降自己场上的「娱乐伙伴」卡以及「异色眼」卡数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(-gc*100)
		d:RegisterEffect(e1)
	end
end
