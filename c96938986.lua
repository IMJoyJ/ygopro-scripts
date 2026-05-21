--共振虫
-- 效果：
-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只5星以上的昆虫族怪兽加入手卡。
-- ②：这张卡被除外的场合才能发动。从卡组把「共振虫」以外的1只昆虫族怪兽送去墓地。
function c96938986.initial_effect(c)
	-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只5星以上的昆虫族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96938986,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c96938986.thcon)
	e1:SetTarget(c96938986.thtg)
	e1:SetOperation(c96938986.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从卡组把「共振虫」以外的1只昆虫族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96938986,1))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetTarget(c96938986.tgtg)
	e2:SetOperation(c96938986.tgop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否从场上送去墓地
function c96938986.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中等级5以上且可以加入手牌的昆虫族怪兽
function c96938986.thfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查卡组中是否存在符合条件的卡并设置操作信息
function c96938986.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c96938986.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组将1只5星以上的昆虫族怪兽加入手牌
function c96938986.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,c96938986.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤卡组中「共振虫」以外且可以送去墓地的昆虫族怪兽
function c96938986.tgfilter(c)
	return c:IsRace(RACE_INSECT) and not c:IsCode(96938986) and c:IsAbleToGrave()
end
-- 效果②的发动准备，检查卡组中是否存在符合条件的卡并设置操作信息
function c96938986.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c96938986.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组将1只「共振虫」以外的昆虫族怪兽送去墓地
function c96938986.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,c96938986.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
