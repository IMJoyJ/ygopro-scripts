--サイバー・オーガ
-- 效果：
-- 把这张卡从手卡丢弃去墓地。自己场上存在的1只「电子食人魔」进行的战斗只有1只无效，并且直到下次战斗结束时攻击力上升2000。这个效果在对方回合也能发动。
function c64268668.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地。自己场上存在的1只「电子食人魔」进行的战斗只有1只无效，并且直到下次战斗结束时攻击力上升2000。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64268668,0))  --"战斗无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c64268668.atkcon)
	e1:SetCost(c64268668.atkcost)
	e1:SetTarget(c64268668.atktg)
	e1:SetOperation(c64268668.atkop)
	c:RegisterEffect(e1)
end
-- 验证发动条件：当前处于战斗阶段，且自己场上有表侧表示的「电子食人魔」正在进行战斗。
function c64268668.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽。
	local d=Duel.GetAttackTarget()
	-- 判断当前是否处于战斗阶段（从战斗阶段开始到战斗阶段结束）。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
		and ((a and a:IsControler(tp) and a:IsFaceup() and a:IsCode(64268668))
		or (d and d:IsControler(tp) and d:IsFaceup() and d:IsCode(64268668)))
end
-- 验证并执行发动代价：将手牌中的此卡送去墓地。
function c64268668.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡作为代价丢弃去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 验证并选择自己场上正在进行战斗的「电子食人魔」作为效果的对象。
function c64268668.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取当前进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽。
	local d=Duel.GetAttackTarget()
	if chk==0 then
		if a:IsControler(tp) then return a:IsCanBeEffectTarget(e)
		else return d:IsCanBeEffectTarget(e) end
	end
	-- 如果攻击怪兽由自己控制，则将该攻击怪兽设为效果的对象。
	if a:IsControler(tp) then return Duel.SetTargetCard(a)
	-- 如果被攻击怪兽由自己控制，则将该被攻击怪兽设为效果的对象。
	else return Duel.SetTargetCard(d) end
end
-- 执行效果：无效对象怪兽的攻击，并使其攻击力上升2000，直到下次战斗结束。
function c64268668.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在且表侧表示，则无效此次攻击，并执行后续效果。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.NegateAttack() then
		-- 并且直到下次战斗结束时攻击力上升2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(2000)
		tc:RegisterEffect(e1)
		-- 直到下次战斗结束时
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetOperation(c64268668.resetop)
		e2:SetLabelObject(e1)
		tc:RegisterEffect(e2)
	end
end
-- 在伤害步骤结束时（即下次战斗结束时），重置攻击力上升的效果，并清除此重置效果自身。
function c64268668.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
