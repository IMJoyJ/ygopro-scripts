--魔妖廻天
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选「魔妖回天」以外的1张「魔妖」卡加入手卡或送去墓地。
function c2364438.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选「魔妖回天」以外的1张「魔妖」卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,2364438+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c2364438.target)
	e1:SetOperation(c2364438.activate)
	c:RegisterEffect(e1)
end
-- 定义符合条件的卡片：持有「魔妖」字段、不是「魔妖回天」自身，并且可以被加入手卡或送去墓地。
function c2364438.filter(c)
	return c:IsSetCard(0x121) and not c:IsCode(2364438) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果发动前的目标判断函数：仅在卡组中存在至少1张符合条件的卡时，该效果才能发动。
function c2364438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在满足过滤条件的1张卡，以此作为效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c2364438.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理时的操作：从卡组选出符合条件的1张「魔妖」卡，根据玩家选择将其加入手卡或送去墓地。
function c2364438.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要操作的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「魔妖」卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c2364438.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 如果选中的卡可以加入手卡，且（不能送去墓地或玩家选择加入手卡时）则执行回手处理；否则执行送墓处理。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认这张加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
