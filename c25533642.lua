--オルターガイスト・メリュシーク
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时，以对方场上1张卡为对象才能发动。那张卡送去墓地。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「幻变骚灵·寻道梅露辛」以外的1只「幻变骚灵」怪兽加入手卡。
function c25533642.initial_effect(c)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时，以对方场上1张卡为对象才能发动。那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25533642,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c25533642.tgcon)
	e2:SetTarget(c25533642.tgtg)
	e2:SetOperation(c25533642.tgop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡从场上送去墓地的场合才能发动。从卡组把「幻变骚灵·寻道梅露辛」以外的1只「幻变骚灵」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25533642,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,25533642)
	e3:SetCondition(c25533642.thcon)
	e3:SetTarget(c25533642.thtg)
	e3:SetOperation(c25533642.thop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件：战斗伤害的承受方是对方（ep不等于tp），即这张卡给与对方战斗伤害时。
function c25533642.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ②效果的发动时点：从对方场上选择1张可以送去墓地的卡作为对象，并设置将此卡送去墓地的操作信息。
function c25533642.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 发动时检查对方场上是否存在至少1张可以送去墓地的卡作为对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作者发送选择提示消息，显示“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让操作者从对方场上选择1张可以送去墓地的卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本连锁的操作信息设置为“把对象卡送去墓地”，数量为1，供其他效果（如星尘龙）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果处理：取得效果对象，若该卡仍与效果关联（未离场或未解除联系），则将其送去墓地。
function c25533642.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一张效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡从场上（原位置为场上）送去墓地，即满足“从场上送去墓地的场合”。
function c25533642.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选卡组中符合条件的卡：持有「幻变骚灵」字段、是怪兽卡、不是这张卡本身、且可以加入手卡。
function c25533642.thfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_MONSTER) and not c:IsCode(25533642) and c:IsAbleToHand()
end
-- ③效果发动时点：确认卡组中存在至少1只符合条件的「幻变骚灵」怪兽，并设置检索加入手卡的操作信息。
function c25533642.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1只符合条件的「幻变骚灵」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25533642.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息为从卡组检索1张卡加入手卡（对象未确定，预计数量1），用于响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只符合条件的「幻变骚灵」怪兽加入手卡，并向对方确认检索到的卡。
function c25533642.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者发送选择提示消息，显示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「幻变骚灵」怪兽。
	local g=Duel.SelectMatchingCard(tp,c25533642.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
