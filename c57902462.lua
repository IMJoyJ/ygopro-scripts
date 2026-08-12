--聖導騎士イシュザーク
-- 效果：
-- 这张卡战斗破坏怪兽时，那只怪兽从游戏中除外。
function c57902462.initial_effect(c)
	-- 这张卡战斗破坏怪兽时，那只怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57902462,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c57902462.condition)
	e1:SetTarget(c57902462.target)
	e1:SetOperation(c57902462.operation)
	c:RegisterEffect(e1)
end
-- 检查与这张卡进行战斗的怪兽是否存在，且该怪兽是否已被战斗破坏
function c57902462.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果发动的目标确认，作为必发效果直接返回true，并设置将战斗破坏的怪兽除外的操作信息
function c57902462.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 设置当前连锁的操作信息为：将1张与此卡战斗的怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 效果处理，获取与此卡战斗的怪兽，若其仍与本次战斗关联，则将其除外
function c57902462.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将该怪兽以效果、表侧表示的形式除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
