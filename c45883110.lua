--導きの聖女クエム
-- 效果：
-- 这个卡名在规则上也当作「教导」卡、「死狱乡」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把1只「阿不思的落胤」或者1张有那个卡名记述的卡从卡组送去墓地。
-- ②：自己·对方的卡从额外卡组离开的场合，以除「引导的圣女 奎姆」外的自己墓地1只「阿不思的落胤」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
function c45883110.initial_effect(c)
	-- 将卡名「阿不思的落胤」（卡号68468459）登记到本卡的记述卡名列表中，使后续的aux.IsCodeOrListed能判断「是阿不思的落胤」或「记述了阿不思的落胤」的卡。
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
-- 定义①中从卡组送墓的筛选函数：选择1张「阿不思的落胤」或记述其卡名的、且能被送去墓地的卡。
function c45883110.tgfilter(c)
	-- 筛选条件：c的卡名是「阿不思的落胤」或卡面记述了该卡名，并且c可以被送去墓地。
	return aux.IsCodeOrListed(c,68468459) and c:IsAbleToGrave()
end
-- ①的发动条件与操作信息设置：满足发动条件时确认卡组存在符合条件的卡，并登记将1张卡送去墓地的处理信息。
function c45883110.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中存在至少1张符合条件的「阿不思的落胤」或记述其卡名的卡，效果才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c45883110.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将1张卡从卡组送去墓地的操作信息（不取对象，数量为1，涉及玩家tp的卡组区域）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：从卡组挑选1张符合条件的卡送去墓地。
function c45883110.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组中筛选并选择1张满足tgfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c45883110.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②的发动条件：本次离开原位置的事件涉及的卡中，存在从额外卡组离开的卡。
function c45883110.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
-- 定义②的复活目标筛选函数：自己墓地中除本卡以外的「阿不思的落胤」或记述其卡名的怪兽，且该怪兽可以被特殊召唤。
function c45883110.spfilter(c,e,tp)
	-- 筛选条件：c是「阿不思的落胤」或记述其卡名的卡，并且c不是「引导的圣女 奎姆」自身。
	return aux.IsCodeOrListed(c,68468459) and not c:IsCode(45883110)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件与取对象设定：确认自己场上有空位、墓地存在符合条件的对象后，选择对象并登记特殊召唤信息。
function c45883110.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45883110.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1张符合条件的对象卡（同时该卡能成为效果对象）。
		and Duel.IsExistingTarget(c45883110.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以取对象方式从自己墓地选择1张符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c45883110.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时将对象怪兽特殊召唤的操作信息，对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②的效果处理：将效果发动时选择的对象怪兽特殊召唤到自己场上。
function c45883110.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示形式特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
