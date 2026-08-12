--灼熱の火霊使いヒータ
-- 效果：
-- 包含炎属性怪兽的怪兽2只
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只炎属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的炎属性怪兽加入手卡。
function c48815792.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只包含炎属性怪兽的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,c48815792.lcheck)
	c:EnableReviveLimit()
	-- ①：以对方墓地1只炎属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48815792,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48815792)
	e1:SetTarget(c48815792.sptg)
	e1:SetOperation(c48815792.spop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48815792,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,48815793)
	e2:SetCondition(c48815792.thcon)
	e2:SetTarget(c48815792.thtg)
	e2:SetOperation(c48815792.thop)
	c:RegisterEffect(e2)
end
-- 连接素材中必须包含至少1只炎属性怪兽
function c48815792.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_FIRE)
end
-- 过滤满足条件的怪兽，使其可以被特殊召唤到场上
function c48815792.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置效果目标为对方墓地的1只炎属性怪兽
function c48815792.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c48815792.spfilter(chkc,e,tp,zone) end
	-- 检查是否有足够的怪兽区用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c48815792.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c48815792.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c48815792.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 判断此卡是否因战斗或对方效果被破坏且在主要怪兽区被召唤过
function c48815792.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的怪兽，使其守备力不超过1500且为炎属性
function c48815792.thfilter(c)
	return c:IsDefenseBelow(1500) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置效果目标为从卡组检索1只符合条件的怪兽
function c48815792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48815792.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c48815792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c48815792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
