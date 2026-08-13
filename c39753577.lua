--魔妖変生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
-- ①：丢弃1张手卡，从自己墓地的怪兽以及除外的自己怪兽之中以1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会成为对方的效果的对象。
function c39753577.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。①：丢弃1张手卡，从自己墓地的怪兽以及除外的自己怪兽之中以1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,39753577+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c39753577.cost)
	e1:SetTarget(c39753577.target)
	e1:SetOperation(c39753577.activate)
	c:RegisterEffect(e1)
	-- 注册一个特殊召唤活动计数器（代号39753577），用于检测本回合是否已进行过非「魔妖」的额外卡组特殊召唤，作为发动条件限制。
	Duel.AddCustomActivityCounter(39753577,ACTIVITY_SPSUMMON,c39753577.counterfilter)
end
-- 计数器过滤函数：如果怪兽不是从额外卡组特殊召唤，或者是从额外卡组特殊召唤的「魔妖」怪兽，则返回true（不增加计数）；否则返回false（增加计数，表示进行过限制外的特殊召唤）。
function c39753577.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x121)
end
-- 代价函数：检查发动条件（本回合未进行过违规特殊召唤且手牌有可丢弃的卡），丢弃1张手卡，并给发动者附加本回合不能从额外卡组特殊召唤非「魔妖」怪兽的誓约限制。
function c39753577.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：本回合自定义特殊召唤计数为0（未进行过非「魔妖」的额外特殊召唤），且手牌中存在可丢弃的卡。
	if chk==0 then return Duel.GetCustomActivityCount(39753577,tp,ACTIVITY_SPSUMMON)==0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌丢弃1张卡作为发动代价，丢弃原因为代价+丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 这张卡发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c39753577.splimit)
	-- 将自肃效果e1注册到当前玩家，使该限制在本回合内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制判定：若被特殊召唤的怪兽来自额外卡组且不是「魔妖」怪兽，则禁止该特殊召唤。
function c39753577.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end
-- 对象筛选函数：选择「魔妖」怪兽，且从墓地来的怪兽可直接选择，从除外区来的怪兽需为表侧表示，并确认其能被效果特殊召唤为表侧表示。
function c39753577.spfilter(c,e,tp)
	return c:IsSetCard(0x121) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 目标函数：进行取对象及发动合法性判定，从自己墓地或除外区选择1只符合条件的「魔妖」怪兽，并设置特殊召唤的操作信息。
function c39753577.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c39753577.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区有空位，且存在符合条件的「魔妖」怪兽可以作为效果对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c39753577.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 显示选择提示（HINTMSG_SPSUMMON），请玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地和除外区选择1只符合条件的「魔妖」怪兽作为效果对象，并自动登记为当前连锁对象。
	local g1=Duel.SelectTarget(tp,c39753577.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本次效果将进行特殊召唤，对象为g1，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 效果处理函数：将对象怪兽特殊召唤；若特殊召唤成功，则给它赋予本回合不会成为对方效果对象的抗性。
function c39753577.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，并以表侧表示将其特殊召唤成功，然后才执行后续抗性赋予。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不会成为对方的效果的对象。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置抗性效果的判定值，使该怪兽不会成为对方玩家的卡的效果对象（aux.tgoval实现）。
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
