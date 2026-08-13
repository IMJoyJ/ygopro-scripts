--DDアーク
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以对方场上1只灵摆召唤的怪兽为对象才能发动。那只怪兽和这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡被效果破坏的场合才能发动。从自己的额外卡组把「DD 方舟」以外的1只表侧表示的「DD」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36614113.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡发动、进行灵摆召唤，并注册灵摆相关的基础效果。
	aux.EnablePendulumAttribute(c)
	-- ←1 【灵摆】 1→ 这个卡名的灵摆效果1回合只能使用1次。①：以对方场上1只灵摆召唤的怪兽为对象才能发动。那只怪兽和这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36614113,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,36614113)
	e1:SetTarget(c36614113.destg)
	e1:SetOperation(c36614113.desop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】这个卡名的怪兽效果1回合只能使用1次。①：这张卡被效果破坏的场合才能发动。从自己的额外卡组把「DD 方舟」以外的1只表侧表示的「DD」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36614113,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,36614114)
	e2:SetCondition(c36614113.spcon)
	e2:SetTarget(c36614113.sptg)
	e2:SetOperation(c36614113.spop)
	c:RegisterEffect(e2)
end
-- 灵摆效果的发动条件与目标指定：确认对象为对方场上1只灵摆召唤的怪兽，发动时选择该怪兽并将自身加入对象组，设置破坏2张卡的操作信息。
function c36614113.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_PENDULUM) end
	-- 发动时判定：检查对方场上是否存在1只灵摆召唤的怪兽且能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_PENDULUM) end
	-- 向玩家显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1只灵摆召唤的怪兽作为效果对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsSummonType,tp,0,LOCATION_MZONE,1,1,nil,SUMMON_TYPE_PENDULUM)
	g:AddCard(e:GetHandler())
	-- 设置破坏操作信息，对象为选择的目标和这张卡自身，数量为2张，供后续处理及相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 灵摆效果的解决处理：取得对象怪兽，若对象仍与效果关联，则将对象怪兽和自身同时以效果破坏。
function c36614113.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（此效果只有1张对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽和这张卡（灵摆区域的自身）同时破坏。
		Duel.Destroy(Group.FromCards(tc,e:GetHandler()),REASON_EFFECT)
	end
end
-- 怪兽效果的发动条件：判定这张卡被破坏的原因是否为效果，若是则满足诱发条件。
function c36614113.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选可特殊召唤的怪兽：必须是表侧表示、属于「DD」系列、灵摆怪兽，卡名不是「DD 方舟」，且能够被特殊召唤并有从额外卡组可用的特殊召唤区域。
function c36614113.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and not c:IsCode(36614113)
		-- 确认该怪兽能够被这次效果特殊召唤，且从额外卡组特殊召唤时存在可用的区域空格。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤效果的发动条件与操作信息：检查额外卡组是否存在1只满足条件的灵摆怪兽，并设置从额外卡组特殊召唤1只怪兽的操作信息。
function c36614113.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查额外卡组是否存在1只满足 spfilter 条件的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36614113.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果处理时从额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤的处理：从额外卡组选择1只符合条件的灵摆怪兽，以表侧表示进行分步特殊召唤，并对其附加效果无效化，最后完成特殊召唤。
function c36614113.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己额外卡组选择1只满足 spfilter 条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c36614113.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择了怪兽且能够以表侧表示特殊召唤成功，则继续对其适用效果无效化处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 结束特殊召唤处理，确认并完成所有通过 SpecialSummonStep 进行的特殊召唤。
	Duel.SpecialSummonComplete()
end
