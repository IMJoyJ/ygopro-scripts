--レッドアイズ・インサイト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「真红眼」怪兽送去墓地才能发动。从卡组把「真红眼看破」以外的1张「真红眼」魔法·陷阱卡加入手卡。
function c92353449.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡·卡组把1只「真红眼」怪兽送去墓地才能发动。从卡组把「真红眼看破」以外的1张「真红眼」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92353449+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c92353449.cost)
	e1:SetTarget(c92353449.target)
	e1:SetOperation(c92353449.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·卡组中可以作为代价送去墓地的「真红眼」怪兽
function c92353449.cfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡·卡组把1只「真红眼」怪兽送去墓地
function c92353449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组是否存在至少1只满足条件的「真红眼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92353449.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡·卡组中1只满足条件的「真红眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c92353449.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中「真红眼看破」以外的「真红眼」魔法·陷阱卡，且能加入手卡
function c92353449.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(92353449) and c:IsAbleToHand()
end
-- 效果的目标处理：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function c92353449.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「真红眼看破」以外的「真红眼」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92353449.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理：从卡组把1张「真红眼看破」以外的「真红眼」魔法·陷阱卡加入手卡
function c92353449.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「真红眼看破」以外的「真红眼」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c92353449.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
