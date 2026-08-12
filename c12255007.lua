--EMホタルクス
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，对方怪兽的攻击宣言时把自己场上1只「娱乐伙伴」怪兽解放才能发动。那次攻击无效，那之后战斗阶段结束。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，自己场上的「娱乐伙伴」怪兽或者「异色眼」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c12255007.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在怪兽区域存在，自己场上的「娱乐伙伴」怪兽或者「异色眼」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c12255007.aclimit)
	e1:SetCondition(c12255007.actcon)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方怪兽的攻击宣言时把自己场上1只「娱乐伙伴」怪兽解放才能发动。那次攻击无效，那之后战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1)
	e2:SetCondition(c12255007.condition)
	e2:SetCost(c12255007.cost)
	e2:SetOperation(c12255007.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为魔法·陷阱卡的发动
function c12255007.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断攻击怪兽是否为我方的「娱乐伙伴」或「异色眼」怪兽
function c12255007.actcon(e)
	-- 获取此次攻击的怪兽
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x9f,0x99)
end
-- 判断是否为对方怪兽的攻击宣言
function c12255007.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 设置解放费用的处理函数
function c12255007.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9f) end
	-- 选择满足条件的解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x9f)
	-- 将选中的怪兽解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 设置效果的发动处理函数
function c12255007.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	if Duel.NegateAttack() then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
