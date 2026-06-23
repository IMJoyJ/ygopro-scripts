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
-- 检查被选为攻击对象的怪兽是否为表侧表示、属于玩家控制、且名字带有「自然」
function c25866285.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsFaceup() and ec:IsControler(tp) and ec:IsSetCard(0x2a)
end
-- 检查这张卡是否可以作为代价送去墓地
function c25866285.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 无效此次攻击，并跳过对方的战斗阶段
function c25866285.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	if Duel.NegateAttack() then
		-- 跳过对方玩家的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
