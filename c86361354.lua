--同族感電ウィルス
-- 效果：
-- 1回合1次，把手卡1只怪兽从游戏中除外才能发动。和为这个效果发动而从游戏中除外的怪兽相同种族的场上表侧表示存在的怪兽全部破坏。
function c86361354.initial_effect(c)
	-- 1回合1次，把手卡1只怪兽从游戏中除外才能发动。和为这个效果发动而从游戏中除外的怪兽相同种族的场上表侧表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86361354,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c86361354.cost)
	e1:SetTarget(c86361354.target)
	e1:SetOperation(c86361354.operation)
	c:RegisterEffect(e1)
end
-- 定义手卡除外代价的过滤条件：必须是可作为代价除外的怪兽，且场上存在至少1只与其相同种族的表侧表示怪兽
function c86361354.cfilter(c)
	local rc=c:GetRace()
	return rc~=0 and c:IsAbleToRemoveAsCost()
		-- 检查场上是否存在至少1只与该手卡怪兽相同种族的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c86361354.dfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,rc)
end
-- 定义要破坏的怪兽的过滤条件：场上表侧表示且种族与除外怪兽相同
function c86361354.dfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 效果发动的代价处理：检查并从手卡将1只怪兽表侧表示除外，并记录其种族
function c86361354.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在可作为除外代价且场上有同种族怪兽存在的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86361354.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 在系统缓存中设置提示信息，提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1张满足过滤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c86361354.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetRace())
	-- 将选择的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动的目标确认：获取要破坏的怪兽组并设置破坏的操作信息
function c86361354.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有与作为代价除外的怪兽相同种族的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c86361354.dfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置破坏效果的操作信息，指定要破坏的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行：获取符合条件的怪兽并将其全部破坏
function c86361354.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有与作为代价除外的怪兽相同种族的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c86361354.dfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	-- 破坏所有获取到的符合条件的场上表侧表示怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
