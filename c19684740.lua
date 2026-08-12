--妖精騎士イングナル
-- 效果：
-- 6星怪兽×3
-- ①：1回合1次，把这张卡2个超量素材取除才能发动。这张卡以外的场上的卡全部回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
function c19684740.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为6的怪兽进行3次叠放
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
-- 效果的费用处理函数，检查并移除2个超量素材作为发动代价
function c19684740.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果的目标设定函数，检测场上是否存在可送回手卡的卡并设置连锁信息
function c19684740.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否场上存在满足条件的卡（可送回手卡）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取所有满足条件的场上卡（可送回手卡）
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁操作信息，指定将卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置连锁限制，防止对方连锁此效果的发动
	Duel.SetChainLimit(c19684740.chlimit)
end
-- 连锁限制函数，仅允许发动玩家进行连锁
function c19684740.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果的处理函数，将符合条件的场上卡送回手卡
function c19684740.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的场上卡（排除自身）
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将卡组中的卡以效果原因送回手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
