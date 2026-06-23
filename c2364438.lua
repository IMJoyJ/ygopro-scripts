--魔妖廻天
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选「魔妖回天」以外的1张「魔妖」卡加入手卡或送去墓地。
function c2364438.initial_effect(c)
	-- ①：从卡组选「魔妖回天」以外的1张「魔妖」卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,2364438+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c2364438.target)
	e1:SetOperation(c2364438.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「魔妖」卡（不含魔妖回天），且该卡可以加入手卡或送去墓地。
function c2364438.filter(c)
	return c:IsSetCard(0x121) and not c:IsCode(2364438) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果的发动条件，检查玩家手牌中是否存在满足条件的「魔妖」卡。
function c2364438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未进入确认阶段，则检查卡组中是否存在满足条件的「魔妖」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c2364438.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果的发动处理，选择一张满足条件的卡并决定将其加入手卡或送去墓地。
function c2364438.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张满足条件的「魔妖」卡。
	local g=Duel.SelectMatchingCard(tp,c2364438.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断该卡是否可以加入手卡，若可以则由玩家选择是加入手卡还是送去墓地。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认该卡的卡面信息。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
