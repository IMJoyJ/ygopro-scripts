--異次元の女戦士
-- 效果：
-- ①：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那些进行战斗的各自怪兽除外。
function c7572887.initial_effect(c)
	-- ①：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那些进行战斗的各自怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7572887,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c7572887.target)
	e1:SetOperation(c7572887.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检查与准备阶段，确认自身和对方怪兽是否可以被除外，并收集进行战斗的怪兽作为除外操作的对象。
function c7572887.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽。
	local t=Duel.GetAttackTarget()
	if chk==0 then
		return (t==c and a:IsAbleToRemove())
			or (a==c and t~=nil and t:IsAbleToRemove())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if t~=nil and t:IsRelateToBattle() then g:AddCard(t) end
	-- 设置连锁的操作信息，表明此效果的处理包含将进行战斗的怪兽除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理阶段，获取进行战斗的双方怪兽，过滤出仍与本次战斗有关联的卡片并将其表侧表示除外。
function c7572887.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取效果处理时本次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 因效果将仍与战斗关联的怪兽以表侧表示除外。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
