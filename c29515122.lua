--重機王ドボク・ザーク
-- 效果：
-- 5星怪兽×3
-- 1回合1次，把这张卡1个超量素材取除才能发动。从对方卡组上面把3张卡送去墓地。这个效果送去墓地的卡之中有怪兽卡的场合，把最多有那个数量的对方场上的卡破坏。
function c29515122.initial_effect(c)
	-- 为这张卡添加以任意3只5星怪兽为素材的XYZ召唤手续，使其可以通过超量召唤出场。
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
-- 发动代价的处理：先检查这张卡是否有1个超量素材可供取除作为代价，若有则实际取除1个超量素材。
function c29515122.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动时的目标设定：检查对方是否可以把卡组顶端3张卡送去墓地，并登记本效果包含从卡组送墓地的处理信息，但此时不选择具体卡片。
function c29515122.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：对方玩家必须能够将卡组顶端的3张卡送去墓地，否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,3) end
	-- 设置连锁操作信息，声明本效果将把对方卡组顶端的3张卡送去墓地，用于后续发动检测和时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 过滤函数：判断一张卡是否在墓地且为怪兽卡，用于统计这次因效果送去墓地的怪兽卡数量。
function c29515122.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 效果处理：先将对方卡组顶端3张卡送去墓地，统计其中怪兽卡数量；若有怪兽卡被送去墓地，则选择对方场上最多为该数量的卡并破坏；若没有则效果处理结束。
function c29515122.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将对方卡组顶端的3张卡送去墓地，实际执行送墓操作。
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	-- 获取上一次卡片操作（送墓）实际被操作的卡片组，即被送去墓地的那3张卡。
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c29515122.cfilter,nil)
	if ct==0 then return end
	-- 向当前玩家发送选择提示，提示内容为“请选择要破坏的卡”，为后续选择卡片做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1到ct张卡（ct为本次送墓的怪兽卡数量），任意卡片均可被选择，用于作为破坏对象。
	local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if dg:GetCount()==0 then return end
	-- 中断当前效果链，使此后的破坏处理与之前的送墓处理不在同一时点进行，避免被当作同时处理。
	Duel.BreakEffect()
	-- 手动为选中的破坏对象显示“被选为对象”的动画，并登记这些卡为本次效果关联的对象。
	Duel.HintSelection(dg)
	-- 将选中的卡片以效果原因破坏，完成破坏处理。
	Duel.Destroy(dg,REASON_EFFECT)
end
