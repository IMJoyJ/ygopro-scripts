--魔導法皇 ハイロン
-- 效果：
-- 魔法师族7星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。选最多有自己墓地的名字带有「魔导书」的魔法卡数量的对方场上的魔法·陷阱卡破坏。
function c92918648.initial_effect(c)
	-- 设置XYZ召唤手续：魔法师族7星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),7,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。选最多有自己墓地的名字带有「魔导书」的魔法卡数量的对方场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92918648,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c92918648.cost)
	e1:SetTarget(c92918648.target)
	e1:SetOperation(c92918648.operation)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）：取除这张卡的1个超量素材
function c92918648.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己墓地的名字带有「魔导书」的魔法卡
function c92918648.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 过滤条件：对方场上的魔法·陷阱卡
function c92918648.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的可行性检测与操作信息设置
function c92918648.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己墓地是否存在至少1张名字带有「魔导书」的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92918648.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检测对方场上是否存在至少1张魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c92918648.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c92918648.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息：预估破坏对方场上的至少1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理（Operation）的执行逻辑
function c92918648.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己墓地的名字带有「魔导书」的魔法卡数量
	local ct=Duel.GetMatchingGroupCount(c92918648.cfilter,tp,LOCATION_GRAVE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择最多等同于墓地「魔导书」魔法卡数量的对方场上的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c92918648.filter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 给选中的卡片显示被选择的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡片因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
