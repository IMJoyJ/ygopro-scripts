--EMホタルクス
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，对方怪兽的攻击宣言时把自己场上1只「娱乐伙伴」怪兽解放才能发动。那次攻击无效，那之后战斗阶段结束。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，自己场上的「娱乐伙伴」怪兽或者「异色眼」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c12255007.initial_effect(c)
	-- 调用辅助函数为该卡注册灵摆怪兽属性，使其可以作为灵摆卡发动、进行灵摆召唤等。
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
-- 作为EFFECT_CANNOT_ACTIVATE的Value函数：判定对方发动的效果是否为魔法·陷阱卡的发动（类型为EFFECT_TYPE_ACTIVATE），若是则禁止发动。
function c12255007.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 怪兽效果适用条件：当前攻击怪兽必须是自己场上的「娱乐伙伴」或「异色眼」怪兽，并且攻击宣言正在进行。
function c12255007.actcon(e)
	-- 获取当前攻击宣言的怪兽对象，用于后续判断其控制者和种族字段。
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x9f,0x99)
end
-- 灵摆效果①的发动条件：对方（1-tp）怪兽进行攻击宣言。
function c12255007.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言怪兽的控制者是对方，即不为效果发动者。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 发动代价函数：解放自己场上1只「娱乐伙伴」怪兽；包含代价检测（chk==0）与实际选择解放怪兽并解放的步骤。
function c12255007.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）检查自己场上是否存在至少1只可解放的「娱乐伙伴」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9f) end
	-- 选择自己场上1只「娱乐伙伴」怪兽作为要解放的代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x9f)
	-- 以解放为代价将所选择的怪兽送去墓地（解放），reason=REASON_COST表示作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果处理：先无效对方怪兽的攻击，若成功则插入中断并跳过对方的战斗阶段，使其战斗阶段结束。
function c12255007.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateAttack()无效当前攻击，若无效成功（未被其他效果防止）则进入后续处理。
	if Duel.NegateAttack() then
		-- 中断当前效果链，使后续跳过战斗阶段成为另一次独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 跳过对方（1-tp）的战斗阶段（PHASE_BATTLE），在战斗阶段结束步骤时重置（RESET_PHASE+PHASE_BATTLE_STEP）；value=1表示直接进入结束步骤（跳过战斗阶段）。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
