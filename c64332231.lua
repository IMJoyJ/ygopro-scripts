--聖刻神龍－エネアード
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的手卡·场上的怪兽任意数量解放，选那个数量的场上的卡破坏。
function c64332231.initial_effect(c)
	-- 添加XYZ召唤手续：8星怪兽×2
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的手卡·场上的怪兽任意数量解放，选那个数量的场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64332231,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c64332231.descost)
	e1:SetTarget(c64332231.destg)
	e1:SetOperation(c64332231.desop)
	c:RegisterEffect(e1)
end
-- 效果发动的代价（Cost）：把这张卡1个超量素材取除
function c64332231.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动判定：检查自己手卡·场上是否有可解放的怪兽，以及场上是否有可破坏的卡
function c64332231.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·场上是否存在至少1只可因效果解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,true,nil)
		-- 且检查场上是否存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有的卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：预计破坏场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：解放自己手卡·场上任意数量的怪兽，并破坏相同数量的场上的卡
function c64332231.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上卡片的总数（作为最大解放数量的上限）
	local ct1=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 玩家从手卡·场上选择任意数量（1张以上且不超过场上卡片总数）的可解放怪兽
	local rg=Duel.SelectReleaseGroupEx(tp,nil,1,ct1,REASON_EFFECT,true,nil)
	-- 解放选中的怪兽，并获取实际解放的数量
	local ct2=Duel.Release(rg,REASON_EFFECT)
	if ct2==0 then return end
	-- 中断当前效果处理，使后续的破坏处理与解放处理不视为同时进行
	Duel.BreakEffect()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择与解放数量相同数量的场上的卡
	local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct2,ct2,nil)
	-- 给选中的卡片显示被选为对象的动画效果
	Duel.HintSelection(dg)
	-- 破坏选中的卡
	Duel.Destroy(dg,REASON_EFFECT)
end
