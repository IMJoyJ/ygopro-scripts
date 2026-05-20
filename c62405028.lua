--溟界の滓－ナイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从卡组把1只爬虫类族·光属性怪兽送去墓地。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「溟界」魔法·陷阱卡加入手卡。
function c62405028.initial_effect(c)
	-- ①：把这张卡从手卡送去墓地才能发动。从卡组把1只爬虫类族·光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62405028,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,62405028)
	e1:SetCost(c62405028.tgcost)
	e1:SetTarget(c62405028.tgtg)
	e1:SetOperation(c62405028.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「溟界」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62405028,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,62405029)
	e2:SetTarget(c62405028.srtg)
	e2:SetOperation(c62405028.srop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- ①号效果的代价（Cost）函数：检查并把自身从手卡送去墓地
function c62405028.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中的爬虫类族·光属性怪兽，且能送去墓地
function c62405028.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
-- ①号效果的目标（Target）函数：检查卡组中是否存在符合条件的怪兽，并设置送去墓地的操作信息
function c62405028.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的爬虫类族·光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62405028.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的操作（Operation）函数：从卡组选择1只爬虫类族·光属性怪兽送去墓地
function c62405028.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1只满足条件的爬虫类族·光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c62405028.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：卡组中的「溟界」魔法·陷阱卡，且能加入手卡
function c62405028.srfilter(c)
	return c:IsSetCard(0x161) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②号效果的目标（Target）函数：检查卡组中是否存在符合条件的「溟界」魔陷卡，并设置检索的操作信息
function c62405028.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「溟界」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62405028.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的操作（Operation）函数：从卡组选择1张「溟界」魔法·陷阱卡加入手卡并给对方确认
function c62405028.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「溟界」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c62405028.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
