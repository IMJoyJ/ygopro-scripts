--サイバース・ウィキッド
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：连接召唤的这张卡不会被战斗·效果破坏。
-- ②：这张卡所连接区的电子界族怪兽不会被效果破坏。
-- ③：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1只电子界族怪兽除外才能发动。从卡组把1只电子界族调整加入手卡。
function c52698008.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c52698008.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：这张卡所连接区的电子界族怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c52698008.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1只电子界族怪兽除外才能发动。从卡组把1只电子界族调整加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52698008,0))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,52698008)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c52698008.thcon)
	e4:SetCost(c52698008.thcost)
	e4:SetTarget(c52698008.thtg)
	e4:SetOperation(c52698008.thop)
	c:RegisterEffect(e4)
end
-- 效果适用条件：此卡为连接召唤方式出场
function c52698008.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果适用对象判断：所连接区的电子界族怪兽
function c52698008.indtg(e,c)
	return c:IsRace(RACE_CYBERSE) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 特殊召唤成功时的判断函数：判断是否为连接区的怪兽或其位置是否在连接区
function c52698008.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 诱发效果发动条件：非自身特殊召唤且有连接区怪兽特殊召唤
function c52698008.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(c52698008.thcfilter,1,nil,c)
end
-- 除外卡的过滤条件：墓地中的电子界族怪兽且可作为代价除外
function c52698008.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价：从墓地选择1只电子界族怪兽除外
function c52698008.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可作为代价
	if chk==0 then return Duel.IsExistingMatchingCard(c52698008.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡进行除外操作
	local g=Duel.SelectMatchingCard(tp,c52698008.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 执行将卡除外的操作
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检索卡的过滤条件：卡组中电子界族调整怪兽
function c52698008.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果发动时的处理：设置检索目标
function c52698008.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52698008.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要进行检索操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动后的处理：选择并加入手牌
function c52698008.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡进行加入手牌操作
	local g=Duel.SelectMatchingCard(tp,c52698008.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 执行将卡加入手牌的操作
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选卡
		Duel.ConfirmCards(1-tp,g)
	end
end
