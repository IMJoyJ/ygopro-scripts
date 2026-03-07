--クリボール
-- 效果：
-- ①：对方怪兽的攻击宣言时，把这张卡从手卡送去墓地才能发动。那只攻击怪兽变成守备表示。
-- ②：仪式召唤进行的场合，可以作为需要的等级数值的怪兽之内的1只，把墓地的这张卡除外。
function c33245030.initial_effect(c)
	-- 效果原文内容：①：对方怪兽的攻击宣言时，把这张卡从手卡送去墓地才能发动。那只攻击怪兽变成守备表示。
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
	-- 效果原文内容：②：仪式召唤进行的场合，可以作为需要的等级数值的怪兽之内的1只，把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断攻击方是否为对方
function c33245030.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 规则层面作用：支付将此卡送去墓地的代价
function c33245030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面作用：将此卡从手牌送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面作用：设置效果目标，确认攻击怪兽是否为攻击表示且可改变表示形式
function c33245030.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 规则层面作用：获取当前攻击怪兽
		local at=Duel.GetAttacker()
		return at:IsAttackPos() and at:IsCanChangePosition()
	end
end
-- 规则层面作用：处理效果发动时的怪兽表示形式改变
function c33245030.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前攻击怪兽
	local at=Duel.GetAttacker()
	if at:IsAttackPos() and at:IsRelateToBattle() then
		-- 规则层面作用：将攻击怪兽变为守备表示
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
	end
end
