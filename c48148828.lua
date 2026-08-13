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
-- 发动时的条件检查：获取与这张卡战斗的怪兽，若该怪兽仍与本次战斗关联且处于战斗破坏确定状态，则允许发动并登记除外效果。
function c48148828.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsStatus(STATUS_BATTLE_DESTROYED) end
	-- 登记本次连锁要除外的对象为那只战斗对象，效果分类为除外，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 效果处理时：再次获取战斗对象，若仍在本次战斗中有效关联，则将其除外。
function c48148828.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将被战斗破坏的怪兽以表侧表示从游戏中除外。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
