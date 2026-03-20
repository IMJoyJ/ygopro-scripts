--ゴーストリックの駄天使
-- 效果：
-- 4星怪兽×2
-- 这张卡也能在「鬼计惰天使」以外的自己场上的「鬼计」超量怪兽上面重叠来超量召唤。这张卡持有的超量素材数量变成10时，自己决斗胜利。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「鬼计」魔法·陷阱卡加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。把手卡1张「鬼计」卡在这张卡下面重叠作为超量素材。
function c53334641.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2,c53334641.ovfilter,aux.Stringid(53334641,0))  --"是否在「鬼计」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡持有的超量素材数量变成10时，自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c53334641.winop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「鬼计」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53334641,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c53334641.thcost)
	e2:SetTarget(c53334641.thtg)
	e2:SetOperation(c53334641.thop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。把手卡1张「鬼计」卡在这张卡下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53334641,2))  --"素材增加"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c53334641.mttg)
	e3:SetOperation(c53334641.mtop)
	c:RegisterEffect(e3)
end
-- 判断是否为「鬼计」超量怪兽且不是此卡本身，用于XYZ召唤条件过滤。
function c53334641.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d) and c:IsType(TYPE_XYZ) and not c:IsCode(53334641)
end
-- 当此卡的叠放数量达到10时，令当前玩家以指定理由胜利。
function c53334641.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_GHOSTRICK_SPOILEDANGEL=0x1b
	if e:GetHandler():GetOverlayCount()==10 then
		-- 令当前玩家以指定理由决斗胜利。
		Duel.Win(tp,WIN_REASON_GHOSTRICK_SPOILEDANGEL)
	end
end
-- 支付1个超量素材作为代价，用于发动效果①。
function c53334641.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足「鬼计」魔法或陷阱卡条件的卡，用于检索。
function c53334641.thfilter(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将从卡组检索一张「鬼计」魔法或陷阱卡。
function c53334641.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在至少1张满足条件的「鬼计」魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53334641.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索一张「鬼计」魔法或陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果①的处理，选择并加入手牌。
function c53334641.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的一张卡。
	local g=Duel.SelectMatchingCard(tp,c53334641.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足「鬼计」且可作为叠放素材的卡，用于效果②。
function c53334641.mtfilter(c)
	return c:IsSetCard(0x8d) and c:IsCanOverlay()
end
-- 设置效果②的目标判定条件，检查是否在手牌中存在满足条件的卡。
function c53334641.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查是否在手牌中存在至少1张满足条件的「鬼计」卡。
		and Duel.IsExistingMatchingCard(c53334641.mtfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 执行效果②的处理，选择并叠放至此卡。
function c53334641.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从手牌中选择满足条件的一张卡。
	local g=Duel.SelectMatchingCard(tp,c53334641.mtfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡叠放于此卡上。
		Duel.Overlay(c,g)
	end
end
