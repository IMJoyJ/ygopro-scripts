--ガード・ヘッジ
-- 效果：
-- 战斗伤害计算时，把这张卡从手卡送去墓地发动。自己场上存在的怪兽不会被那次战斗破坏，攻击力直到这个回合的结束阶段时变成一半数值。
function c59042331.initial_effect(c)
	-- 战斗伤害计算时，把这张卡从手卡送去墓地发动。自己场上存在的怪兽不会被那次战斗破坏，攻击力直到这个回合的结束阶段时变成一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59042331,0))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c59042331.atkcon)
	e1:SetCost(c59042331.atkcost)
	e1:SetOperation(c59042331.atkop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：检查进行战斗的怪兽是否为自己场上的怪兽，并将其记录为效果的标签对象
function c59042331.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方场上的怪兽，则将目标怪兽切换为被攻击的怪兽（即自己场上的怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsControler(tp)
end
-- 检查并执行发动代价：将手牌中的这张卡送去墓地
function c59042331.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：使进行战斗的自己怪兽不会被该次战斗破坏，且攻击力直到回合结束时变成一半
function c59042331.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 自己场上存在的怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 攻击力直到这个回合的结束阶段时变成一半数值。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(math.ceil(tc:GetAttack()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
