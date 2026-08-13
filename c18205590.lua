--天架ける星因士
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「星骑士」怪兽为对象才能发动。和那只怪兽卡名不同的1只「星骑士」怪兽从卡组特殊召唤，作为对象的怪兽回到卡组。只要这个效果特殊召唤的怪兽在场上表侧表示存在，自己不是「星骑士」怪兽不能特殊召唤。
function c18205590.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「星骑士」怪兽为对象才能发动。和那只怪兽卡名不同的1只「星骑士」怪兽从卡组特殊召唤，作为对象的怪兽回到卡组。只要这个效果特殊召唤的怪兽在场上表侧表示存在，自己不是「星骑士」怪兽不能特殊召唤。
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
-- 过滤函数：检查怪兽是否满足作为发动对象条件——表侧表示、是「星骑士」怪兽、可以返回卡组，并且卡组中存在卡名不同且可特殊召唤的「星骑士」怪兽。
function c18205590.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x9c) and c:IsAbleToDeck()
		-- 确认卡组中存在至少1只与对象怪兽卡名不同的「星骑士」怪兽可被特殊召唤。
		and Duel.IsExistingMatchingCard(c18205590.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数：检查卡组中的卡是否可作为特殊召唤对象——是「星骑士」怪兽、与对象怪兽卡名不同、且满足特殊召唤条件。
function c18205590.spfilter(c,e,tp,code)
	return c:IsSetCard(0x9c) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时与连锁处理时的目标指定：在连锁处理时验证指定对象是否合法；发动时检查是否有可用怪兽区域以及是否存在可选对象。
function c18205590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18205590.filter(chkc,e,tp) end
	-- 发动条件检查：自己场上必须有至少1个可用的怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己场上存在至少1只满足条件的「星骑士」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c18205590.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己场上1只符合条件的「星骑士」怪兽作为效果对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c18205590.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：将选定对象送去卡组（返回卡组）的效果类别与数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记操作信息：从卡组特殊召唤1只怪兽的效果类别、来源位置与持有者。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：确认场地空位；取得对象怪兽；从卡组选择1只卡名不同的「星骑士」特殊召唤；对象怪兽返回卡组洗牌；给特殊召唤的怪兽附加“不是「星骑士」不能特殊召唤”的自肃效果。
function c18205590.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己场上是否有可用怪兽区域，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果发动时选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「星骑士」怪兽，要求卡名与对象怪兽不同且可以被特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c18205590.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		-- 将选择的「星骑士」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 将对象怪兽返回持有者卡组并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 只要这个效果特殊召唤的怪兽在场上表侧表示存在，自己不是「星骑士」怪兽不能特殊召唤。
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
-- 自肃判定：若怪兽不是「星骑士」则不能特殊召唤，用于限制后续特殊召唤。
function c18205590.splimit(e,c)
	return not c:IsSetCard(0x9c)
end
