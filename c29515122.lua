--重機王ドボク・ザーク
-- 效果：
-- 5星怪兽×3
-- 1回合1次，把这张卡1个超量素材取除才能发动。从对方卡组上面把3张卡送去墓地。这个效果送去墓地的卡之中有怪兽卡的场合，把最多有那个数量的对方场上的卡破坏。
function c29515122.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为5且数量为3的怪兽作为素材
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。从对方卡组上面把3张卡送去墓地。这个效果送去墓地的卡之中有怪兽卡的场合，把最多有那个数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29515122,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c29515122.cost)
	e1:SetTarget(c29515122.target)
	e1:SetOperation(c29515122.operation)
	c:RegisterEffect(e1)
end
-- 检查并移除自身1个超量素材作为发动代价
function c29515122.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果发动时的操作信息，确定将从对方卡组顶部送去墓地3张卡
function c29515122.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方玩家是否可以将卡组顶部3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,3) end
	-- 设置连锁操作信息，指定将从对方卡组送去墓地3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 定义过滤函数，用于判断卡片是否为墓地中的怪兽卡
function c29515122.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 执行效果处理流程，包括从对方卡组送去墓地3张卡、检测是否有怪兽卡、选择并破坏对方场上等量的卡
function c29515122.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组顶部3张卡送去墓地
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	-- 获取刚刚执行的卡组操作所涉及的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c29515122.cfilter,nil)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上最多与送去墓地的怪兽数量相等的卡片
	local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if dg:GetCount()==0 then return end
	-- 中断当前效果处理，使后续效果视为错时处理
	Duel.BreakEffect()
	-- 显示所选卡片被作为对象的动画效果
	Duel.HintSelection(dg)
	-- 将所选的对方场上的卡片破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
