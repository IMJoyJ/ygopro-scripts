--影霊衣の大魔道士
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被效果解放的场合才能发动。从卡组把1只魔法师族「影灵衣」仪式怪兽加入手卡。
-- ②：这张卡被除外的场合才能发动。从卡组把「影灵衣大魔道士」以外的1只「影灵衣」怪兽送去墓地。
function c27796375.initial_effect(c)
	-- ①：这张卡被效果解放的场合才能发动。从卡组把1只魔法师族「影灵衣」仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27796375,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27796375)
	e1:SetCondition(c27796375.thcon)
	e1:SetCost(c27796375.cost)
	e1:SetTarget(c27796375.thtg)
	e1:SetOperation(c27796375.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从卡组把「影灵衣大魔道士」以外的1只「影灵衣」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27796375,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,27796375)
	e2:SetCost(c27796375.cost)
	e2:SetTarget(c27796375.tgtg)
	e2:SetOperation(c27796375.tgop)
	c:RegisterEffect(e2)
end
-- 支付效果代价，向对方玩家提示本效果发动
function c27796375.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示本效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果发动条件：由效果导致的解放
function c27796375.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检索满足条件的卡片组：魔法师族、仪式怪兽、影灵衣系列
function c27796375.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡片类型为仪式魔法师族影灵衣怪兽
function c27796375.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c27796375.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并加入手牌
function c27796375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27796375.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的卡片组：非影灵衣大魔道士、影灵衣系列、怪兽
function c27796375.tgfilter(c)
	return c:IsSetCard(0xb4) and not c:IsCode(27796375) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果处理时要检索的卡片类型为影灵衣怪兽（非本卡）
function c27796375.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c27796375.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并送去墓地
function c27796375.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27796375.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
