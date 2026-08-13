--灼熱の火霊使いヒータ
-- 效果：
-- 包含炎属性怪兽的怪兽2只
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只炎属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的炎属性怪兽加入手卡。
function c48815792.initial_effect(c)
	-- 为这张卡添加连接召唤手续：素材必须是2只怪兽，且素材组中须包含至少1只炎属性怪兽。
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
-- 连接素材检查函数：确认用于连接召唤的素材组中是否存在至少1只炎属性怪兽。
function c48815792.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_FIRE)
end
-- 特殊召唤对象过滤条件：对象必须是炎属性怪兽，并且能够以表侧表示特殊召唤到这张卡连接区对应的自己场上区域。
function c48815792.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的目标设定函数：计算这张卡当前可用的连接区域，并校验对象是否位于对方墓地且满足特殊召唤条件；发动判定时还需确认自己场上存在空位且有可选的炎属性对象。
function c48815792.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c48815792.spfilter(chkc,e,tp,zone) end
	-- 效果发动条件判定：确认自己场上存在可用的主要怪兽区域空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件判定：确认对方墓地存在至少1只满足特殊召唤条件的炎属性怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c48815792.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 向操作玩家发出“选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从对方墓地选择1只符合条件的炎属性怪兽，并将其登记为这个效果的对象。
	local g=Duel.SelectTarget(tp,c48815792.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置当前连锁的操作信息为“特殊召唤1只对象怪兽”，供其他卡效果进行联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联且对象仍与该效果关联，则计算新的连接区域，并将对象怪兽特殊召唤到这张卡连接区对应的自己场上。
function c48815792.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 取出发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽以表侧表示特殊召唤到这张卡连接区对应的自己场上区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- ②效果的发动条件判定：这张卡必须是连接召唤出场，且在场上被战斗破坏，或被对方控制者的效果所破坏。
function c48815792.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤条件：满足守备力1500以下、炎属性且能够加入手卡的怪兽。
function c48815792.thfilter(c)
	return c:IsDefenseBelow(1500) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- ②效果的目标设定：发动时检查卡组是否存在符合条件的炎属性怪兽，并登记“从卡组检索加入手牌”的操作信息。
function c48815792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：确认卡组中存在至少1只满足检索条件的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48815792.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为“从卡组将1张卡加入手牌”，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的炎属性怪兽加入手牌，并展示给对方玩家确认。
function c48815792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发出“选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让操作玩家从卡组选择1只满足条件的炎属性怪兽（处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c48815792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张怪兽展示给对方玩家确认，以证明检索的真实性。
		Duel.ConfirmCards(1-tp,g)
	end
end
