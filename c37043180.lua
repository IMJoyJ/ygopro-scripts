--異次元の戦士
-- 效果：
-- ①：这张卡和怪兽进行战斗的伤害计算后发动。那些进行战斗的各自怪兽除外。
function c37043180.initial_effect(c)
	-- ①：这张卡和怪兽进行战斗的伤害计算后发动。那些进行战斗的各自怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37043180,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c37043180.target)
	e1:SetOperation(c37043180.operation)
	c:RegisterEffect(e1)
end
-- 在效果发动时，检查战斗目标是否存在，获取战斗双方怪兽，过滤与战斗相关的卡，并设置除外操作信息。
function c37043180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此次战斗是否有攻击目标，确保效果在卡与怪兽战斗时才能发动。
	if chk==0 then return Duel.GetAttackTarget()~=nil end
	-- 获取此次战斗的攻击方怪兽。
	local a=Duel.GetAttacker()
	-- 获取此次战斗的被攻击方怪兽。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 设置操作信息，指定要除外的卡为与战斗相关的怪兽，并设置数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 在效果处理时，获取战斗双方怪兽，过滤与战斗相关的卡，并将这些卡正面表示除外。
function c37043180.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取战斗的攻击方怪兽。
	local a=Duel.GetAttacker()
	-- 在效果处理时，获取战斗的被攻击方怪兽。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将战斗相关的怪兽以正面表示形式除外。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
