--エレメントセイバー・マカニ
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。从卡组把「元素灵剑士·随风」以外的1只「元素灵剑士」怪兽或者「灵神」怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c19036557.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。从卡组把「元素灵剑士·随风」以外的1只「元素灵剑士」怪兽或者「灵神」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19036557,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c19036557.thcost)
	e1:SetTarget(c19036557.thtg)
	e1:SetOperation(c19036557.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19036557,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c19036557.atttg)
	e2:SetOperation(c19036557.attop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查手卡或卡组中是否存在满足条件的「元素灵剑士」怪兽（且能作为cost送去墓地）
function c19036557.costfilter(c,tp)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查手卡或卡组中是否存在满足条件的「元素灵剑士」怪兽（且能作为cost送去墓地）
		and Duel.IsExistingMatchingCard(c19036557.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 效果处理函数，用于处理将1只「元素灵剑士」怪兽送去墓地作为cost
function c19036557.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到效果影响，该效果与卡号61557074相关
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 检查是否满足条件，即手卡或卡组中存在满足costfilter的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19036557.costfilter,tp,loc,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并将其送去墓地
	local tc=Duel.SelectMatchingCard(tp,c19036557.costfilter,tp,loc,0,1,1,nil,tp):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 提示对方玩家该卡被使用
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的卡送去墓地作为效果的代价
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 过滤函数，用于检索卡组中满足条件的「元素灵剑士」或「灵神」怪兽
function c19036557.thfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(19036557) and c:IsSetCard(0x400d,0x113) and c:IsAbleToHand()
end
-- 效果处理函数，用于设置检索效果的目标
function c19036557.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19036557.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于处理从卡组检索怪兽并加入手牌
function c19036557.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c19036557.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果处理函数，用于处理墓地效果的属性宣言
function c19036557.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可选属性中宣言一个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置效果处理信息，表示将使该卡离开墓地并改变属性
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，用于处理墓地效果的属性变更
function c19036557.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 创建一个改变属性的效果，使其在回合结束时恢复原属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
