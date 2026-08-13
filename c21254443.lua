--星遺物の導き
-- 效果：
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「星遗物」怪兽除外，以自己墓地2只怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c21254443.initial_effect(c)
	-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「星遗物」怪兽除外，以自己墓地2只怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c21254443.cost)
	e1:SetTarget(c21254443.target)
	e1:SetOperation(c21254443.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选条件：要除外的是「星遗物」怪兽，且必须是手牌或自己场上表侧表示的怪兽；若自己主要怪兽区没有可用空格，则只能选择场上的怪兽（除外后空出格子）。
function c21254443.cfilter(c,ft)
	return c:IsSetCard(0xfe) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and (ft>0 or c:IsLocation(LOCATION_MZONE))
end
-- 效果的代价处理：先检查是否存在满足条件的「星遗物」怪兽，若存在则让玩家从手牌以及自己场上的表侧表示怪兽中选择1只，将其表侧除外作为发动代价。
function c21254443.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区当前可用的空格数，用于判断是否可以从手牌除外（无空格时只能除外场上怪兽）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价检测阶段：确认存在至少1张满足cfilter条件的「星遗物」怪兽可供除外，以此判定代价能否支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c21254443.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,ft) end
	-- 显示“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌以及自己场上的表侧表示怪兽中选取1只满足条件的「星遗物」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c21254443.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的代价卡以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义对象怪兽的筛选条件：该墓地怪兽可以被当前效果特殊召唤（满足特殊召唤条件且不受其他限制）。
function c21254443.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的对象选择处理：确认自己主要怪兽区有空格、当前没有青眼精灵龙禁止同时特殊召唤2只以上怪兽的效果适用，且墓地有可特殊召唤的怪兽；满足后选择对象。
function c21254443.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21254443.filter(chkc,e,tp) end
	-- 目标检测阶段首先要求自己主要怪兽区至少存在1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 进一步要求墓地存在至少2只可特殊召唤且能成为对象的怪兽。
		and Duel.IsExistingTarget(c21254443.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择2只满足条件的怪兽，并将它们设为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,c21254443.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置连锁处理信息：本效果将特殊召唤2只怪兽，供后续时点与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理阶段：确认仍有空格后，取出仍相关的对象；若对象数超过空格则选择可召唤的数量；若青眼精灵龙效果适用且对象多于1则无法同时特殊召唤，直接终止；否则逐只特殊召唤并附加不能攻击效果，最后完成特殊召唤。
function c21254443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己主要怪兽区的可用空格数，决定实际能特殊召唤多少只。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取得连锁中登记的对象卡，并过滤出仍然与这张卡效果相关的卡（未离场或未被无效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 当可用空格不足时，显示“请选择要特殊召唤的卡”的提示，让玩家从对象中选出实际可召唤的数量。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将当前这只对象怪兽以表侧表示特殊召唤（作为多只同时特殊召唤流程中的一步，暂不完成处理）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 结束同时特殊召唤流程，正式完成所有怪兽的特殊召唤并触发相关时点。
	Duel.SpecialSummonComplete()
end
