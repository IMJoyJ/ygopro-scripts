--転生炎獣の炎虞
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只「转生炎兽」怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材把1只「转生炎兽」连接怪兽连接召唤。这个回合，这个效果连接召唤的怪兽不能攻击，不能把效果发动。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「转生炎兽」连接怪兽为对象才能发动。那只怪兽回到额外卡组。
function c28534130.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡把1只「转生炎兽」怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材把1只「转生炎兽」连接怪兽连接召唤。这个回合，这个效果连接召唤的怪兽不能攻击，不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28534130+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28534130.target)
	e1:SetOperation(c28534130.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「转生炎兽」连接怪兽为对象才能发动。那只怪兽回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28534130,0))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动代价：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c28534130.tdtg)
	e2:SetOperation(c28534130.tdop)
	c:RegisterEffect(e2)
end
-- 定义连接素材筛选：额外卡组的「转生炎兽」连接怪兽能够以mc为素材进行连接召唤。
function c28534130.lkfilter(c,mc)
	return c:IsSetCard(0x119) and c:IsLinkSummonable(nil,mc)
end
-- 定义手牌特召筛选：手牌怪兽为「转生炎兽」且可被效果特殊召唤，同时额外存在可用其作素材的「转生炎兽」连接怪兽。
function c28534130.spfilter(c,e,tp)
	return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在至少1只可以该手牌怪兽为素材进行连接召唤的「转生炎兽」连接怪兽。
		and Duel.IsExistingMatchingCard(c28534130.lkfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 效果①的发动条件判定：确认本回合能特殊召唤2次、自己主要怪兽区有空位，且手牌存在满足特召和连接素材条件的「转生炎兽」怪兽。
function c28534130.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合还能进行2次特殊召唤（用于特召手牌怪兽和连接召唤）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己主要怪兽区是否有空位用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在满足条件的「转生炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c28534130.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果①的操作信息：将进行2次特殊召唤（手牌+额外），用于相关卡牌判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果①处理：从手牌选1只「转生炎兽」怪兽效果无效特召，再以其为素材在额外卡组选1只「转生炎兽」连接怪兽连接召唤，并对该连接怪兽附加不能攻击、不能发效果的限制。
function c28534130.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足条件的「转生炎兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28534130.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧表示特殊召唤；若特召失败则整个处理终止。
	if not tc or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	local c=e:GetHandler()
	-- 从手卡把1只「转生炎兽」怪兽效果无效特殊召唤中的“效果无效”。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 结束特殊召唤步骤，完成连续特殊召唤的处理。
	Duel.SpecialSummonComplete()
	-- 立即刷新场地状态，确保后续判定基于最新信息。
	Duel.AdjustAll()
	if not tc:IsLocation(LOCATION_MZONE) then return end
	-- 获取额外卡组中所有可以以该特召怪兽为素材进行连接召唤的「转生炎兽」连接怪兽。
	local tg=Duel.GetMatchingGroup(c28534130.lkfilter,tp,LOCATION_EXTRA,0,nil,tc)
	if tg:GetCount()>0 then
		-- 显示“选择要连接召唤的怪兽”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 这个回合，这个效果连接召唤的怪兽不能攻击，不能把效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e3:SetOperation(c28534130.regop)
		sc:RegisterEffect(e3)
		-- 以该特召怪兽为素材，从额外卡组进行「转生炎兽」连接怪兽的连接召唤。
		Duel.LinkSummon(tp,sc,nil,tc)
	end
end
-- 连接召唤成功时，给那只怪兽附加“不能攻击、不能把效果发动”的限制，持续到回合结束。
function c28534130.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetOwner()
	local c=e:GetHandler()
	-- 这个回合，这个效果连接召唤的怪兽不能攻击，不能把效果发动。②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「转生炎兽」连接怪兽为对象才能发动。那只怪兽回到额外卡组。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e2,true)
	e:Reset()
end
-- 定义②效果的对象筛选：自己墓地的「转生炎兽」连接怪兽且能回到额外卡组。
function c28534130.tdfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- ②效果的发动条件与取对象处理：选择自己墓地1只符合条件的「转生炎兽」连接怪兽为对象。
function c28534130.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28534130.tdfilter(chkc) end
	-- 发动时确认自己墓地存在至少1只符合条件的「转生炎兽」连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28534130.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“选择要返回卡组的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1只「转生炎兽」连接怪兽作为对象。
	local g=Duel.SelectTarget(tp,c28534130.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置②效果的操作信息：对象卡将返回额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- ②效果处理：将对象怪兽返回持有者的额外卡组。
function c28534130.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回持有者的额外卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
