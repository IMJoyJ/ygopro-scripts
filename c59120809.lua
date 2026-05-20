--スケアクロー・トライヒハート
-- 效果：
-- 效果怪兽3只
-- 这张卡不用连接召唤不能特殊召唤。
-- ①：场上的表侧表示怪兽变成守备表示。
-- ②：场上的这张卡不受守备表示怪兽发动的效果影响。
-- ③：1回合1次，这张卡在额外怪兽区域存在的场合，以自己墓地1只3星「恐吓爪牙族」怪兽为对象才能发动。那只怪兽特殊召唤，从卡组把1只「恐吓爪牙族」怪兽加入手卡。这个效果发动过的回合，自己不是「恐吓爪牙族」怪兽不能特殊召唤。
function c59120809.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：效果怪兽3只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3,3)
	-- 这张卡不用连接召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过连接召唤的方式特殊召唤
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	-- ①：场上的表侧表示怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡不受守备表示怪兽发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c59120809.immval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，这张卡在额外怪兽区域存在的场合，以自己墓地1只3星「恐吓爪牙族」怪兽为对象才能发动。那只怪兽特殊召唤，从卡组把1只「恐吓爪牙族」怪兽加入手卡。这个效果发动过的回合，自己不是「恐吓爪牙族」怪兽不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59120809,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c59120809.condition)
	e4:SetTarget(c59120809.target)
	e4:SetOperation(c59120809.operation)
	c:RegisterEffect(e4)
end
-- 免疫效果的判定函数：检查发动效果的怪兽在场上是否为守备表示
function c59120809.immval(e,re)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and re:IsActivated() and re:GetActivateLocation()==LOCATION_MZONE
		and (rc:IsRelateToEffect(re) and rc:IsDefensePos() or not rc:IsRelateToEffect(re) and rc:IsPreviousPosition(POS_DEFENSE))
end
-- 判定此卡是否在额外怪兽区域
function c59120809.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()>4
end
-- 过滤自己墓地中可以特殊召唤的3星「恐吓爪牙族」怪兽
function c59120809.spfilter(c,e,tp)
	return c:IsSetCard(0x17a) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可以加入手卡的「恐吓爪牙族」怪兽
function c59120809.thfilter(c)
	return c:IsSetCard(0x17a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的发动准备：检查场地、墓地和卡组，并选择墓地怪兽作为对象
function c59120809.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59120809.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的3星「恐吓爪牙族」怪兽
		and Duel.IsExistingTarget(c59120809.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己卡组是否存在可检索的「恐吓爪牙族」怪兽
		and Duel.IsExistingMatchingCard(c59120809.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只3星「恐吓爪牙族」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59120809.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的执行：特殊召唤墓地对象，检索卡组怪兽，并施加本回合的特殊召唤限制
function c59120809.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只「恐吓爪牙族」怪兽
		local g2=Duel.SelectMatchingCard(tp,c59120809.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,g2)
		end
	end
	-- 这个效果发动过的回合，自己不是「恐吓爪牙族」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59120809.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤「恐吓爪牙族」以外的怪兽
function c59120809.splimit(e,c)
	return not c:IsSetCard(0x17a)
end
