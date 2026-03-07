--剣闘訓練所
-- 效果：
-- 从自己卡组把1只4星以下的名字带有「剑斗兽」的怪兽加入手卡。
function c35224440.initial_effect(c)
	-- 从自己卡组把1只4星以下的名字带有「剑斗兽」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35224440.target)
	e1:SetOperation(c35224440.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：名字带有「剑斗兽」、等级4以下、可以送去手卡
function c35224440.filter(c)
	return c:IsSetCard(0x1019) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 效果的发动条件判断：检查自己卡组是否存在满足条件的怪兽
function c35224440.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断效果是否可以发动：检查自己卡组是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35224440.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息：将要从卡组检索并加入手牌的怪兽数量设为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理：提示选择怪兽并将其加入手牌
function c35224440.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c35224440.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
