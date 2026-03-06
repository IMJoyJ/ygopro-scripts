--ONiサンダー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「雷电哥哥」以外的1只雷族·光属性·4星怪兽加入手卡。
function c27217742.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。从卡组把「雷电哥哥」以外的1只雷族·光属性·4星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27217742,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27217742.thtg)
	e1:SetOperation(c27217742.thop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：雷族·光属性·4星怪兽且不是雷电哥哥且可以加入手牌
function c27217742.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and not c:IsCode(27217742) and c:IsAbleToHand()
end
-- 效果作用：检查是否满足发动条件并设置操作信息
function c27217742.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27217742.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择并处理目标卡片
function c27217742.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c27217742.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
