--ナチュル・スティンクバグ
-- 效果：
-- 自己场上表侧表示存在的名字带有「自然」的怪兽成为攻击对象时，把自己场上表侧表示存在的这张卡送去墓地才能发动。那次攻击无效，战斗阶段结束。
function c25866285.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「自然」的怪兽成为攻击对象时，把自己场上表侧表示存在的这张卡送去墓地才能发动。那次攻击无效，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25866285,0))  --"攻击无效并结束战斗阶段"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c25866285.condition)
	e1:SetCost(c25866285.cost)
	e1:SetOperation(c25866285.operation)
	c:RegisterEffect(e1)
end
-- 判断成为攻击对象的怪兽是否为表侧表示且为自己控制的「自然」字段怪兽，以此作为效果发动条件。
function c25866285.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsFaceup() and ec:IsControler(tp) and ec:IsSetCard(0x2a)
end
-- 代价判定与支付：先确认此卡可作为代价送去墓地，满足后执行将此卡送去墓地的代价操作。
function c25866285.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将发动效果的这张卡自身送入墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：此次攻击无效，并跳过对方战斗阶段；若攻击无效成功则执行跳过。
function c25866285.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 调用 Duel.NegateAttack 无效当前攻击，并检查是否无效成功。
	if Duel.NegateAttack() then
		-- 跳过对方玩家的战斗阶段，使战斗阶段强制结束，并在战斗步骤结束时重置该跳过效果。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
