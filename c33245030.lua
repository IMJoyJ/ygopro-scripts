--クリボール
-- 效果：
-- ①：对方怪兽的攻击宣言时，把这张卡从手卡送去墓地才能发动。那只攻击怪兽变成守备表示。
-- ②：仪式召唤进行的场合，可以作为需要的等级数值的怪兽之内的1只，把墓地的这张卡除外。
function c33245030.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，把这张卡从手卡送去墓地才能发动。那只攻击怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33245030.condition)
	e1:SetCost(c33245030.cost)
	e1:SetTarget(c33245030.target)
	e1:SetOperation(c33245030.operation)
	c:RegisterEffect(e1)
	-- ②：仪式召唤进行的场合，可以作为需要的等级数值的怪兽之内的1只，把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 判定发动条件：对方怪兽进行攻击宣言。
function c33245030.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击宣言的怪兽是对方怪兽（控制者为1-tp）。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 设置发动代价：检查手卡的这张卡能否作为代价送去墓地，若能则执行代价。
function c33245030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡从手卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动时的目标检测：确认攻击怪兽处于攻击表示且能够变更表示形式。
function c33245030.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前攻击宣言的怪兽。
		local at=Duel.GetAttacker()
		return at:IsAttackPos() and at:IsCanChangePosition()
	end
end
-- 效果处理：将那只攻击怪兽变为表侧守备表示（若其仍与本次战斗相关）。
function c33245030.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	if at:IsAttackPos() and at:IsRelateToBattle() then
		-- 将该攻击怪兽的表示形式变更为表侧守备表示。
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
	end
end
