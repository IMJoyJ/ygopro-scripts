--導きの聖女クエム
-- 效果：
-- 这个卡名在规则上也当作「教导」卡、「死狱乡」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把1只「阿不思的落胤」或者1张有那个卡名记述的卡从卡组送去墓地。
-- ②：自己·对方的卡从额外卡组离开的场合，以除「引导的圣女 奎姆」外的自己墓地1只「阿不思的落胤」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
function c45883110.initial_effect(c)
	-- 注册卡片效果中涉及的其他卡名代码，使该卡能被识别为具有「阿不思的落胤」卡名记述的卡片
	aux.AddCodeList(c,68468459)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。把1只「阿不思的落胤」或者1张有那个卡名记述的卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45883110,0))  --"从卡组把卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,45883110)
	e1:SetTarget(c45883110.tgtg)
	e1:SetOperation(c45883110.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的卡从额外卡组离开的场合，以除「引导的圣女 奎姆」外的自己墓地1只「阿不思的落胤」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45883110,1))  --"墓地怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_LEAVE_DECK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,45883111)
	e3:SetCondition(c45883110.spcon)
	e3:SetTarget(c45883110.sptg)
	e3:SetOperation(c45883110.spop)
	c:RegisterEffect(e3)
end
-- 定义用于筛选卡组中符合条件的卡片的过滤函数，检查是否为「阿不思的落胤」或其记述的卡片且能被送去墓地
function c45883110.tgfilter(c)
	-- 检查卡片是否为「阿不思的落胤」或其记述的卡片且能被送去墓地
	return aux.IsCodeOrListed(c,68468459) and c:IsAbleToGrave()
end
-- 设置效果发动时的处理目标，确认场上存在满足条件的卡牌
function c45883110.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c45883110.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，指定将要处理的卡牌类型为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义效果发动时的处理操作，提示玩家选择要送去墓地的卡牌并执行送去墓地操作
function c45883110.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,c45883110.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义效果发动条件，检查是否有来自额外卡组的卡离开
function c45883110.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
-- 定义用于筛选墓地中符合条件的卡片的过滤函数，检查是否为「阿不思的落胤」或其记述的卡片且未为本卡且可特殊召唤
function c45883110.spfilter(c,e,tp)
	-- 检查卡片是否为「阿不思的落胤」或其记述的卡片且不是本卡
	return aux.IsCodeOrListed(c,68468459) and not c:IsCode(45883110)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理目标，确认墓地存在满足条件的卡牌
function c45883110.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45883110.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的卡牌
		and Duel.IsExistingTarget(c45883110.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的卡牌作为目标
	local g=Duel.SelectTarget(tp,c45883110.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，指定将要处理的卡牌类型为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果发动时的处理操作，选择目标卡牌并执行特殊召唤
function c45883110.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡牌
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡牌特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
