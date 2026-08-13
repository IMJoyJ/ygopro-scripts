--フレムベル・パウン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组选择1只守备力200的怪兽加入手卡。
function c28332833.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组选择1只守备力200的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28332833,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c28332833.thcon)
	e1:SetTarget(c28332833.thtg)
	e1:SetOperation(c28332833.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：本卡的当前持有者必须位于墓地，且本卡是被战斗破坏而送去墓地。
function c28332833.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检索过滤条件：怪兽卡且守备力为200，并且能够被加入手卡。
function c28332833.filter(c)
	return c:IsDefense(200) and c:IsAbleToHand()
end
-- 效果发动时的合法性检查和操作信息登记：若卡组中存在符合条件的怪兽，则登记为从卡组检索1张怪兽加入手卡的效果。
function c28332833.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点确认：若自己卡组中不存在符合条件的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28332833.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理信息：本次效果将把1张卡从卡组加入手卡，目标位置为卡组，操作归属为发动玩家。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先提示玩家选择要加入手卡的卡，再从卡组选择1张符合条件的怪兽加入手卡，并向对方确认。
function c28332833.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选出1张满足守备力200且能加入手卡条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c28332833.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的怪兽卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
