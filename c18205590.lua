--天架ける星因士
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「星骑士」怪兽为对象才能发动。和那只怪兽卡名不同的1只「星骑士」怪兽从卡组特殊召唤，作为对象的怪兽回到卡组。只要这个效果特殊召唤的怪兽在场上表侧表示存在，自己不是「星骑士」怪兽不能特殊召唤。
function c18205590.initial_effect(c)
	-- ①：以自己场上1只「星骑士」怪兽为对象才能发动。和那只怪兽卡名不同的1只「星骑士」怪兽从卡组特殊召唤，作为对象的怪兽回到卡组。只要这个效果特殊召唤的怪兽在场上表侧表示存在，自己不是「星骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,18205590+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c18205590.target)
	e1:SetOperation(c18205590.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上满足条件的「星骑士」怪兽，且该怪兽能被送入卡组，并且卡组中存在与该怪兽不同名的「星骑士」怪兽可以特殊召唤。
function c18205590.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x9c) and c:IsAbleToDeck()
		-- 检查卡组中是否存在与目标怪兽不同名的「星骑士」怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c18205590.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，检查卡组中满足条件的「星骑士」怪兽，且该怪兽不能与目标怪兽同名，并且可以被特殊召唤。
function c18205590.spfilter(c,e,tp,code)
	return c:IsSetCard(0x9c) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，即自己场上是否存在满足条件的「星骑士」怪兽作为对象。
function c18205590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18205590.filter(chkc,e,tp) end
	-- 判断自己场上是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的「星骑士」怪兽作为对象。
		and Duel.IsExistingTarget(c18205590.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送入卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上满足条件的「星骑士」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c18205590.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，标记将要送入卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置效果操作信息，标记将要从卡组特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤和送回卡组的操作，并设置后续限制。
function c18205590.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有足够的怪兽区域进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 提示玩家选择要特殊召唤的「星骑士」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的「星骑士」怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c18205590.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		-- 将选中的「星骑士」怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 将目标怪兽送回卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 创建一个永续效果，限制自己不能特殊召唤非「星骑士」怪兽。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c18205590.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
-- 限制效果的目标，禁止非「星骑士」怪兽的特殊召唤。
function c18205590.splimit(e,c)
	return not c:IsSetCard(0x9c)
end
