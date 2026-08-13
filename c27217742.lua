--ONiサンダー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「雷电哥哥」以外的1只雷族·光属性·4星怪兽加入手卡。
function c27217742.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「雷电哥哥」以外的1只雷族·光属性·4星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27217742,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27217742.thtg)
	e1:SetOperation(c27217742.thop)
	c:RegisterEffect(e1)
end
-- 定义检索筛选条件：选择雷族·光属性·4星怪兽，且卡名不为「雷电哥哥」，并满足能加入手卡。
function c27217742.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and not c:IsCode(27217742) and c:IsAbleToHand()
end
-- 效果发动时的目标判定：检查卡组是否存在符合条件的检索目标，并设置将卡组中卡加入手卡的操作信息。
function c27217742.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点确认卡组中是否存在至少1只满足条件的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27217742.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理时将1张卡从卡组加入手卡的操作信息，供连锁判定和后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：从卡组中选择1张符合条件的怪兽加入手卡，并向对方展示确认。
function c27217742.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡（雷族·光属性·4星且非「雷电哥哥」），不取对象。
	local g=Duel.SelectMatchingCard(tp,c27217742.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，加入原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
