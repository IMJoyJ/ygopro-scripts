--カード・フリッパー
-- 效果：
-- 把1张手卡送去墓地发动。把对方场上存在的全部怪兽的表示形式改变。
function c72767833.initial_effect(c)
	-- 把1张手卡送去墓地发动。把对方场上存在的全部怪兽的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c72767833.cost)
	e1:SetTarget(c72767833.target)
	e1:SetOperation(c72767833.activate)
	c:RegisterEffect(e1)
end
-- 过滤可以作为发动代价丢弃并送去墓地的手牌
function c72767833.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理：丢弃1张手牌
function c72767833.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72767833.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,c72767833.costfilter,1,1,REASON_COST)
end
-- 效果发动的目标处理：检查对方场上是否有怪兽，并设置改变表示形式的操作信息
function c72767833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	-- 获取对方场上的所有怪兽
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 设置操作信息，表示该效果会改变对方场上所有怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 效果运行的处理：改变对方场上所有怪兽的表示形式
function c72767833.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有怪兽
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if sg:GetCount()>0 then
		-- 改变这些怪兽的表示形式（表侧攻击变表侧守备，里侧攻击变里侧守备，表侧守备变表侧攻击，里侧守备变表侧攻击）
		Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
