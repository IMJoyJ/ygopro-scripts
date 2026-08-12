--異次元の狂獣
-- 效果：
-- 被这张卡战斗破坏的怪兽从游戏中除外。
function c48148828.initial_effect(c)
	-- 被这张卡战斗破坏的怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48148828,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c48148828.target)
	e1:SetOperation(c48148828.operation)
	c:RegisterEffect(e1)
end
-- 检查战斗中被破坏的怪兽是否有效且处于战斗破坏状态
function c48148828.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsStatus(STATUS_BATTLE_DESTROYED) end
	-- 设置连锁操作信息为除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 执行将战斗破坏的怪兽除外的效果
function c48148828.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 以效果为原因，正面表示除外目标怪兽
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
