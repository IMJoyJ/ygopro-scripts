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
-- 设置效果发动条件并登记除外对象：在伤害计算后，将攻击怪兽和被攻击怪兽中仍与战斗相关的卡作为除外对象。
function c37043180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认存在攻击目标（这张卡正与怪兽进行战斗），否则效果不能发动。
	if chk==0 then return Duel.GetAttackTarget()~=nil end
	-- 获取进行战斗的攻击方怪兽。
	local a=Duel.GetAttacker()
	-- 获取进行战斗的被攻击方怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将筛选出的、仍与这次战斗相关的双方怪兽登记为除外操作的处理对象，并设置数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 效果处理时，再次取得战斗双方怪兽并筛选出仍与战斗相关的卡，然后一并除外。
function c37043180.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击方怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击方怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将筛选出的双方怪兽以表侧表示除外，除外原因为效果。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
