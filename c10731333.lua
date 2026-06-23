--EMオッドアイズ・ミノタウロス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：自己的「娱乐伙伴」怪兽或者「异色眼」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽效果】
-- ①：自己的灵摆怪兽向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己场上的「娱乐伙伴」卡以及「异色眼」卡数量×100。
function c10731333.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「娱乐伙伴」怪兽或者「异色眼」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c10731333.ptg)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆怪兽向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己场上的「娱乐伙伴」卡以及「异色眼」卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c10731333.atkcon)
	e2:SetOperation(c10731333.atkop)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否为「娱乐伙伴」或「异色眼」系列
function c10731333.ptg(e,c)
	return c:IsSetCard(0x9f,0x99)
end
-- 判断场上的「娱乐伙伴」或「异色眼」怪兽是否表侧表示
function c10731333.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99)
end
-- 判断攻击怪兽是否为灵摆怪兽且攻击目标存在且为表侧表示
function c10731333.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	-- 统计场上「娱乐伙伴」或「异色眼」卡的数量
	local gc=Duel.GetMatchingGroupCount(c10731333.atkfilter,tp,LOCATION_ONFIELD,0,nil)
	return a:IsControler(tp) and a:IsType(TYPE_PENDULUM) and d
		and d:IsFaceup() and not d:IsControler(tp) and gc>0
end
-- 执行攻击力变更效果
function c10731333.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽的战斗目标
	local d=Duel.GetAttacker():GetBattleTarget()
	-- 再次统计场上「娱乐伙伴」或「异色眼」卡的数量
	local gc=Duel.GetMatchingGroupCount(c10731333.atkfilter,tp,LOCATION_ONFIELD,0,nil)
	if d:IsRelateToBattle() and d:IsFaceup() then
		-- 使目标怪兽在本次伤害计算时攻击力下降
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(-gc*100)
		d:RegisterEffect(e1)
	end
end
