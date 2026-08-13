--妖精騎士イングナル
-- 效果：
-- 6星怪兽×3
-- ①：1回合1次，把这张卡2个超量素材取除才能发动。这张卡以外的场上的卡全部回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
function c19684740.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要3只等级6的怪兽作为超量素材叠放。
	aux.AddXyzProcedure(c,nil,6,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除才能发动。这张卡以外的场上的卡全部回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19684740,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c19684740.thcost)
	e1:SetTarget(c19684740.thtg)
	e1:SetOperation(c19684740.thop)
	c:RegisterEffect(e1)
end
-- 代价函数：发动前检查这张卡是否有2个超量素材可移除，若有则发动时移除2个超量素材作为代价。
function c19684740.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 发动条件与目标处理函数：确认场上存在这张卡以外的可回手卡的卡，取得这些卡并设置操作信息；同时设置连锁限制，使对方不能对应发动。
function c19684740.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：判断场上是否存在这张卡以外的、可以加入手卡的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 取得这张卡以外的场上所有可以加入手卡的卡，用于记录返回手卡的对象范围。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：声明本效果将把上述所有卡返回持有者手卡，供后续连锁判定及相关效果使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置连锁限制：限制后续可连锁的效果种类或玩家，以达成“对方不能对应发动”的效果。
	Duel.SetChainLimit(c19684740.chlimit)
end
-- 连锁限制判定：只有效果发动者本人（tp==ep）可以连锁此效果，即对方不能连锁发动魔法·陷阱·怪兽效果。
function c19684740.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果处理函数：实际获取这张卡以外的场上所有可以加入手卡的卡，并将它们全部送回持有者手卡。
function c19684740.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次取得这张卡以外的场上所有可回手卡的卡（不取对象，排除这张卡自身）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将所有符合条件的卡以效果原因送回持有者手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
