--ガトムズの緊急指令
-- 效果：
-- ①：场上有「X-剑士」怪兽存在的场合，以自己·对方的墓地的「X-剑士」怪兽合计2只为对象才能发动。那2只怪兽在自己场上特殊召唤。
function c13504844.initial_effect(c)
	-- ①：场上有「X-剑士」怪兽存在的场合，以自己·对方的墓地的「X-剑士」怪兽合计2只为对象才能发动。那2只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c13504844.condition)
	e1:SetTarget(c13504844.target)
	e1:SetOperation(c13504844.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：场上表侧表示且属于「X-剑士」系列的怪兽。
function c13504844.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 定义效果发动条件：自己场上或对方场上存在至少1只符合cfilter条件（表侧表示「X-剑士」怪兽）的卡。
function c13504844.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测以tp方视角看，自己或对方的主要怪兽区是否存在至少1张表侧表示的「X-剑士」怪兽，作为效果可以发动的条件。
	return Duel.IsExistingMatchingCard(c13504844.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 定义可选对象过滤：墓地的「X-剑士」怪兽，且能够被玩家tp用这个效果以表侧表示特殊召唤。
function c13504844.filter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择与合法性检查：确认选择对象必须是自己或对方墓地的「X-剑士」怪兽；若为发动前检查（chk==0），则还需满足青眼精灵龙不在场、自己主怪兽区空位大于1、墓地存在至少2只符合条件的「X-剑士」怪兽。
function c13504844.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c13504844.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少2个可用的主要怪兽区空格，确保能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查双方墓地是否存在至少2只满足filter条件（「X-剑士」且能特殊召唤）的怪兽，且这些卡能够成为此效果的对象。
		and Duel.IsExistingTarget(c13504844.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil,e,tp) end
	-- 给玩家tp弹出选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从双方墓地的「X-剑士」怪兽中选择2只作为效果对象，并自动将这些卡与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,c13504844.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil,e,tp)
	-- 设置当前连锁的操作信息：本次效果要处理的是特殊召唤，对象为已选择的g，数量为2，归属玩家和位置未知（填0）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理时的操作：若青眼精灵龙效果适用中或自己怪兽区空格不足2个则效果不处理；否则取得连锁对象，筛选出仍与效果相关的卡，若恰好为2张则将其在己方场上表侧表示特殊召唤。
function c13504844.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查自己主要怪兽区是否至少有2个可用空格，若不足则不能特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取当前连锁中被选择为对象的卡组，用于后续确认要特殊召唤的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()~=2 then return end
	-- 将筛选出的2只「X-剑士」怪兽在己方场上表侧攻击表示特殊召唤（成功数由引擎计算，本处不检查）。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
