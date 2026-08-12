--D.D.アサイラント
-- 效果：
-- ①：这张卡被和对方怪兽的战斗破坏的伤害计算后发动。那些进行战斗的各自怪兽除外。
function c70074904.initial_effect(c)
	-- ①：这张卡被和对方怪兽的战斗破坏的伤害计算后发动。那些进行战斗的各自怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70074904,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c70074904.condition)
	e1:SetTarget(c70074904.target)
	e1:SetOperation(c70074904.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否满足被战斗破坏确定且是与对方怪兽进行战斗的发动条件
function c70074904.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 进行效果发动的可行性检查，并收集与本次战斗关联的怪兽以确立除外操作信息
function c70074904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local t=Duel.GetAttackTarget()
	if chk==0 then
		return (t==c and a:IsAbleToRemove())
			or (a==c and t~=nil and t:IsAbleToRemove())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if t~=nil and t:IsRelateToBattle() then g:AddCard(t) end
	-- 设置效果处理的操作信息，准备将进行战斗的怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行效果处理，将仍与本次战斗关联的双方怪兽表侧表示除外
function c70074904.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将筛选出的与本次战斗关联的怪兽以效果原因表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
