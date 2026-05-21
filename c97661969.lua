--崔嵬の地霊使いアウス
-- 效果：
-- 包含地属性怪兽的怪兽2只
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只地属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的地属性怪兽加入手卡。
function c97661969.initial_effect(c)
	-- 添加连接召唤手续：2只怪兽，其中必须包含地属性怪兽
	aux.AddLinkProcedure(c,nil,2,2,c97661969.lcheck)
	c:EnableReviveLimit()
	-- ①：以对方墓地1只地属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97661969,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97661969)
	e1:SetTarget(c97661969.sptg)
	e1:SetOperation(c97661969.spop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的地属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97661969,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,97661970)
	e2:SetCondition(c97661969.thcon)
	e2:SetTarget(c97661969.thtg)
	e2:SetOperation(c97661969.thop)
	c:RegisterEffect(e2)
end
-- 连接素材检查：素材组中必须存在至少1只地属性怪兽
function c97661969.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_EARTH)
end
-- 特殊召唤过滤条件：地属性且可以特殊召唤到指定连接区域
function c97661969.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的发动准备（检查是否满足发动条件、选择对象）
function c97661969.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c97661969.spfilter(chkc,e,tp,zone) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在可以特殊召唤到所连接区的地属性怪兽
		and Duel.IsExistingTarget(c97661969.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只地属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97661969.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理（将对象怪兽特殊召唤到所连接区）
function c97661969.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽以表侧表示特殊召唤到所连接区
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- ②效果的发动条件：连接召唤的这张卡被战斗或对方的效果破坏
function c97661969.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤条件：守备力1500以下的地属性怪兽且能加入手卡
function c97661969.thfilter(c)
	return c:IsDefenseBelow(1500) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- ②效果的发动准备（检查卡组中是否有符合条件的卡并设置操作信息）
function c97661969.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在守备力1500以下的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97661969.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理（从卡组检索符合条件的怪兽）
function c97661969.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只守备力1500以下的地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c97661969.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
