--ヴァイロン・キューブ
-- 效果：
-- 这张卡被光属性怪兽的同调召唤使用送去墓地的场合，可以从自己卡组选择1张装备魔法卡加入手卡。
function c41431329.initial_effect(c)
	-- 这张卡被光属性怪兽的同调召唤使用送去墓地的场合，可以从自己卡组选择1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41431329,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c41431329.thcon)
	e1:SetTarget(c41431329.thtg)
	e1:SetOperation(c41431329.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：此卡当前位于墓地，且是作为光属性怪兽的同调召唤素材被使用而被送去墓地时，条件成立。
function c41431329.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and c:GetReasonCard():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 筛选卡组中满足条件的卡片：必须是装备魔法卡，并且能够加入手卡。
function c41431329.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：先检查卡组是否存在至少1张符合条件的装备魔法卡，若存在则登记本次操作将把卡组中的卡加入手卡。
function c41431329.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张符合条件的装备魔法卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41431329.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果会从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际操作：从卡组选择1张符合条件的装备魔法卡加入手卡，并向对方确认。
function c41431329.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示当前玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的装备魔法卡。
	local g=Duel.SelectMatchingCard(tp,c41431329.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
