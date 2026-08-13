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
-- ①效果的COST筛选：确认c是「元素灵剑士」怪兽、可作为COST送入墓地，且卡组中存在满足检索条件的检索目标（排除c本身）。
function c19036557.costfilter(c,tp)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在至少1张满足检索条件的卡，且该卡不是当前选作COST的这张卡（排除自身），以保证COST后一定能有检索目标。
		and Duel.IsExistingMatchingCard(c19036557.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- ①效果的COST执行：先检查是否可以发动（有合法COST），然后从手卡（若「灵神的圣殿」适用则也可从卡组）选择1只「元素灵剑士」怪兽并送去墓地；若选择的是卡组的卡，则消耗「灵神的圣殿」的③效果次数。
function c19036557.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 查询我方是否适用「灵神的圣殿」的效果（即“灵神的圣殿③”的代替COST），并取得该效果对象，用于判断能否从卡组把「元素灵剑士」怪兽作为COST送去墓地。
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 在效果发动合法性检查阶段，确认从当前可选的COST来源（手卡；若适用「灵神的圣殿」则还有卡组）存在至少1张满足costfilter的「元素灵剑士」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19036557.costfilter,tp,loc,0,1,nil,tp) end
	-- 向玩家显示“请选择要送去墓地的卡”的提示框，用于选择要作为COST的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡（或卡组）中选出1张满足costfilter条件的「元素灵剑士」怪兽，并取得该卡作为COST。
	local tc=Duel.SelectMatchingCard(tp,c19036557.costfilter,tp,loc,0,1,1,nil,tp):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 由于使用了「灵神的圣殿」的代替效果从卡组选择COST，向双方展示「灵神的圣殿」的卡片动画，提示该代替效果正在适用。
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的怪兽以COST理由送入墓地，完成发动代价的支付。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 检索目标的筛选条件：是怪兽卡、不是「元素灵剑士·随风」自身、属于「元素灵剑士」或「灵神」系列，并且可以加入手卡。
function c19036557.thfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(19036557) and c:IsSetCard(0x400d,0x113) and c:IsAbleToHand()
end
-- ①效果的发动目标检测：确认发动合法性（卡组存在检索目标），并登记本效果将要把卡组中的1张卡加入手牌的操作信息，以便其他卡进行连锁判断。
function c19036557.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查卡组中是否存在至少1张满足thfilter的检索目标（即「元素灵剑士·随风」以外的「元素灵剑士」怪兽或「灵神」怪兽），否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19036557.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果属于加入手牌的效果，预定从卡组把1张卡加入手牌，用于连锁和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只满足检索条件的「元素灵剑士」怪兽或「灵神」怪兽加入手牌，并向对方展示确认。
function c19036557.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，用于选择检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足thfilter条件的卡，并作为组对象g返回。
	local g=Duel.SelectMatchingCard(tp,c19036557.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果理由加入手牌，完成检索。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手牌的卡展示给对方玩家确认，保证游戏信息透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件与宣言处理：效果在墓地中满足条件即可发动；发动时让玩家宣言1个属性并记录，同时登记涉及墓地卡的操作信息，以应对相关卡片的对应。
function c19036557.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 显示“请选择要宣言的属性”的提示，用于宣言属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从全部属性中排除这张卡当前的属性后，宣言1个属性（通过按位取反排除当前属性）。宣言结果存在效果标签中。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 登记操作信息：本效果涉及墓地中的这张卡（可能使其属性变化，并伴有离场等行为），用于「王家长眠之谷」等效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- ②效果处理：若这张卡仍在墓地且与该效果保持关联，则生成一个改变属性的持续效果，使这张卡在同一回合结束时之前变为所宣言的属性。
function c19036557.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
