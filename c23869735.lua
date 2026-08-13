--化石発掘
-- 效果：
-- ①：丢弃1张手卡，以自己墓地1只恐龙族怪兽为对象才能把这张卡发动。那只恐龙族怪兽特殊召唤。
-- ②：这张卡的①的效果特殊召唤的怪兽只要这张卡在魔法与陷阱区域存在效果无效化，这张卡从场上离开时破坏。那只怪兽破坏时这张卡破坏。
function c23869735.initial_effect(c)
	-- ①：丢弃1张手卡，以自己墓地1只恐龙族怪兽为对象才能把这张卡发动。那只恐龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c23869735.cost)
	e1:SetTarget(c23869735.target)
	e1:SetOperation(c23869735.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上离开时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c23869735.desop)
	c:RegisterEffect(e2)
	-- ②：那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c23869735.descon2)
	e3:SetOperation(c23869735.desop2)
	c:RegisterEffect(e3)
	-- ②：这张卡的①的效果特殊召唤的怪兽只要这张卡在魔法与陷阱区域存在效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
-- 发动代价处理：在效果发动确认阶段检查手牌是否有可丢弃的卡，然后让玩家选择并丢弃1张手卡作为发动代价。
function c23869735.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：chk==0时返回是否存在至少1张可以丢弃的手牌（且不能丢弃本卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃：让玩家从手牌选择1张可以丢弃的卡，以COST+丢弃的理由将其丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选函数：判定怪兽是否为恐龙族，并且能够被当前效果以表侧表示特殊召唤（满足苏生限制和召唤条件）。
function c23869735.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择阶段：先验证连锁处理指定对象时对象在自己墓地且满足条件；再在发动时确认自己怪兽区有空位且墓地存在符合条件的恐龙族怪兽，可进行取对象发动。
function c23869735.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23869735.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否存在可用空格（用于特殊召唤）。若没有空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以成为此效果对象的恐龙族怪兽，且能够特殊召唤。
		and Duel.IsExistingTarget(c23869735.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽（提示文本为“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的恐龙族怪兽，将其设为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,c23869735.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：声明本效果将特殊召唤1只怪兽（用于让其他卡得知此操作并触发响应）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理整体：获取对象怪兽，若对象仍与效果关联且仍为恐龙族，则以表侧表示进行特殊召唤；成功后让本卡与那只怪兽建立永续对象联系；最后完成特殊召唤处理。
function c23869735.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 分步特殊召唤：确认对象与效果关联且仍为恐龙族，若可以特殊召唤则将其以表侧表示特殊召唤到己方场上，同时保留后续建立联系的机会。
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DINOSAUR) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 结束分步特殊召唤流程，触发特殊召唤成功后的相关时点。
	Duel.SpecialSummonComplete()
end
-- 这张卡离场时的诱发效果：如果这张卡的①效果特殊召唤的怪兽仍在怪兽区域，则破坏那只怪兽。
function c23869735.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以卡片效果为原因破坏那只被特殊召唤的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 诱发条件：这张卡的①效果特殊召唤的怪兽被破坏时，返回真（用于触发本卡的破坏效果）。
function c23869735.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当关联怪兽被破坏时，破坏这张卡自身。
function c23869735.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
