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
-- 效果作用
function c37043180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即是否有攻击对象
	if chk==0 then return Duel.GetAttackTarget()~=nil end
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 设置连锁操作信息，将参与战斗的怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 效果作用
function c37043180.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将参与战斗的怪兽除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
