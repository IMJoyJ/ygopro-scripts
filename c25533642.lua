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
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「幻变骚灵·寻道梅露辛」以外的1只「幻变骚灵」怪兽加入手卡。
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
-- 判断是否为对方造成战斗伤害
function c25533642.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 选择对方场上的1张卡作为对象并送去墓地
function c25533642.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 检查对方场上是否存在可送去墓地的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上的1张卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，将选择的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 执行将目标卡送去墓地的操作
function c25533642.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否从场上送去墓地
function c25533642.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤出满足条件的「幻变骚灵」怪兽（非梅露辛）
function c25533642.thfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_MONSTER) and not c:IsCode(25533642) and c:IsAbleToHand()
end
-- 检索满足条件的「幻变骚灵」怪兽并加入手牌
function c25533642.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25533642.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，将检索的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行将符合条件的怪兽加入手牌的操作
function c25533642.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25533642.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
