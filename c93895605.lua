--ヘイト・バスター
-- 效果：
-- ①：自己的恶魔族怪兽被选择作为攻击对象时，以1只攻击怪兽和那1只攻击对象怪兽为对象才能发动。那只攻击怪兽和那只攻击对象怪兽2只破坏，给与对方破坏的攻击怪兽的原本攻击力数值的伤害。
function c93895605.initial_effect(c)
	-- ①：自己的恶魔族怪兽被选择作为攻击对象时，以1只攻击怪兽和那1只攻击对象怪兽为对象才能发动。那只攻击怪兽和那只攻击对象怪兽2只破坏，给与对方破坏的攻击怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c93895605.condition)
	e1:SetTarget(c93895605.target)
	e1:SetOperation(c93895605.activate)
	c:RegisterEffect(e1)
end
-- 检查被选择作为攻击对象的怪兽是否为自己控制的表侧表示恶魔族怪兽
function c93895605.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_FIEND)
end
-- 检查攻击怪兽和攻击对象怪兽是否都在场且能成为效果对象
function c93895605.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取被选择作为攻击对象的怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return a:IsOnField() and a:IsCanBeEffectTarget(e)
		and d:IsOnField() and d:IsCanBeEffectTarget(e) end
	local g=Group.FromCards(a,d)
	-- 将攻击怪兽和攻击对象怪兽注册为效果的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理的操作信息为破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理：若两只怪兽均满足条件，则将其破坏，并给与对方破坏的攻击怪兽原本攻击力数值的伤害
function c93895605.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	-- 获取此效果发动的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if a:IsRelateToEffect(e) and a:IsAttackable() and not a:IsStatus(STATUS_ATTACK_CANCELED)
		and d:IsFaceup() and d:IsRelateToEffect(e) then
		-- 破坏作为对象的两只怪兽
		Duel.Destroy(g,REASON_EFFECT)
		if not a:IsOnField() then
			-- 给与对方被破坏的攻击怪兽原本攻击力数值的伤害
			Duel.Damage(1-tp,a:GetAttack(),REASON_EFFECT)
		end
	end
end
