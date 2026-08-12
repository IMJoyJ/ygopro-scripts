--決戦融合－ファイナル・フュージョン
-- 效果：
-- ①：自己场上的融合怪兽和对方场上的融合怪兽进行战斗的战斗步骤，以那2只融合怪兽为对象才能发动。那次攻击无效，双方玩家受到那2只融合怪兽的攻击力合计数值的伤害。
function c89719143.initial_effect(c)
	-- ①：自己场上的融合怪兽和对方场上的融合怪兽进行战斗的战斗步骤，以那2只融合怪兽为对象才能发动。那次攻击无效，双方玩家受到那2只融合怪兽的攻击力合计数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e1:SetCondition(c89719143.condition)
	e1:SetTarget(c89719143.target)
	e1:SetOperation(c89719143.activate)
	c:RegisterEffect(e1)
end
-- 检查是否为自己场上的融合怪兽与对方场上的融合怪兽进行战斗的战斗步骤
function c89719143.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	return a and at and a:IsFaceup() and a:IsType(TYPE_FUSION) and at:IsFaceup() and at:IsType(TYPE_FUSION)
end
-- 选择进行战斗的2只融合怪兽作为效果对象，并注册伤害的操作信息
function c89719143.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	if chkc then return chkc==a or chkc==at end
	if chk==0 then return a:IsOnField() and a:IsCanBeEffectTarget(e) and at:IsOnField() and at:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果的对象
	Duel.SetTargetCard(a)
	-- 将被攻击怪兽设置为效果的对象
	Duel.SetTargetCard(at)
	local dam=a:GetAttack()+at:GetAttack()
	-- 设置效果处理的操作信息为双方玩家受到伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 无效攻击，并给与双方玩家那2只融合怪兽攻击力合计数值的伤害
function c89719143.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的2只融合怪兽
	local tc1,tc2=Duel.GetFirstTarget()
	local dam=tc1:GetAttack()+tc2:GetAttack()
	-- 尝试无效本次攻击，若成功则继续处理
	if Duel.NegateAttack() then
		if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
			-- 给与对方玩家那2只融合怪兽攻击力合计数值的伤害（分步处理）
			Duel.Damage(1-tp,dam,REASON_EFFECT,true)
			-- 给与自己玩家那2只融合怪兽攻击力合计数值的伤害（分步处理）
			Duel.Damage(tp,dam,REASON_EFFECT,true)
			-- 完成分步伤害处理，触发受到伤害的时点
			Duel.RDComplete()
		end
	end
end
