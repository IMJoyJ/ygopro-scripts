--魔人 ダーク・バルター
-- 效果：
-- 「凭依的血魂」＋「边境的大贤者」
-- 融合召唤这只怪兽，必须用上面所写的卡融合召唤。通常魔法发动时支付1000分，那个通常魔法的效果无效化。这张卡战斗破坏的效果怪兽的效果无效化。
function c80071763.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「凭依的血魂」与「边境的大贤者」，且不能使用融合代替素材
	aux.AddFusionProcCode2(c,52860176,38742075,false,false)
	-- 通常魔法发动时支付1000分，那个通常魔法的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80071763,0))  --"效果无效化"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c80071763.discon)
	e1:SetCost(c80071763.discost)
	e1:SetTarget(c80071763.distg)
	e1:SetOperation(c80071763.disop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏的效果怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c80071763.disop2)
	c:RegisterEffect(e2)
end
-- 定义效果无效化效果的发动条件函数，判断自身是否未被战斗破坏且发动的效果是否为可无效的通常魔法
function c80071763.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断发动的效果是否为魔法卡的发动（通常魔法在发动时其类型为TYPE_SPELL且是EFFECT_TYPE_ACTIVATE），且该连锁效果可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_SPELL and Duel.IsChainDisablable(ev)
end
-- 定义效果无效化效果的Cost函数，用于检查并支付1000点基本分
function c80071763.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 在发动时，让玩家支付1000点基本分
	Duel.PayLPCost(tp,1000)
end
-- 定义效果无效化效果的Target函数，用于设置效果分类和操作信息
function c80071763.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为无效化该魔法卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义效果无效化效果的Operation函数，执行无效化处理
function c80071763.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 定义战斗破坏怪兽时无效其效果的Operation函数，在伤害计算后将战斗破坏的怪兽效果无效化
function c80071763.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 这张卡战斗破坏的效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 这张卡战斗破坏的效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
