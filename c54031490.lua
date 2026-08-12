--紫炎の狼煙
-- 效果：
-- ①：从卡组把1只3星以下的「六武众」怪兽加入手卡。
function c54031490.initial_effect(c)
	-- ①：从卡组把1只3星以下的「六武众」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54031490.target)
	e1:SetOperation(c54031490.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：卡组中卡名含有「六武众」且等级在3星以下、可以加入手卡的怪兽
function c54031490.filter(c)
	return c:IsSetCard(0x103d) and c:IsLevelBelow(3) and c:IsAbleToHand()
end
-- 效果发动的目标与检测：在发动时检查卡组是否存在符合条件的怪兽，并设置操作信息
function c54031490.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查己方卡组是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54031490.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽加入手卡，并给对方确认
function c54031490.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c54031490.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
