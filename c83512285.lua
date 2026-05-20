--ハイパー・ギャラクシー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把「银河眼光子龙」以外的自己场上1只攻击力2000以上的怪兽解放，以对方场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽解放，从自己的手卡·卡组·墓地选1只「银河眼光子龙」特殊召唤。
function c83512285.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把「银河眼光子龙」以外的自己场上1只攻击力2000以上的怪兽解放，以对方场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽解放，从自己的手卡·卡组·墓地选1只「银河眼光子龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,83512285+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c83512285.cost)
	e1:SetTarget(c83512285.target)
	e1:SetOperation(c83512285.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于判断自己场上是否存在可解放的、攻击力2000以上且非「银河眼光子龙」的怪兽，同时对方场上存在可作为对象的攻击力2000以上的怪兽
function c83512285.costfilter(c,tp)
	-- 检查卡片是否由自己控制（或在场上表侧表示）、攻击力是否在2000以上、是否不是「银河眼光子龙」，以及解放后是否能腾出怪兽区域
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsAttackAbove(2000) and not c:IsCode(93717133) and Duel.GetMZoneCount(tp,c)>0
		-- 检查对方场上是否存在满足条件（表侧表示、攻击力2000以上且可被效果解放）的怪兽作为对象
		and Duel.IsExistingTarget(c83512285.rfilter,tp,0,LOCATION_MZONE,1,c)
end
-- 发动代价（Cost）处理：解放自己场上1只「银河眼光子龙」以外的攻击力2000以上的怪兽
function c83512285.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动准备阶段，检查自己场上是否存在至少1只满足条件的怪兽可作为代价解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c83512285.costfilter,1,nil,tp) end
	-- 让玩家选择自己场上1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c83512285.costfilter,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：用于检索手卡·卡组·墓地中可以特殊召唤的「银河眼光子龙」
function c83512285.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：用于筛选对方场上表侧表示、攻击力2000以上且能被效果解放的怪兽
function c83512285.rfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000) and c:IsReleasableByEffect()
end
-- 效果的目标选择（Target）与发动准备处理
function c83512285.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c83512285.rfilter(chkc) end
	-- 检查怪兽区域是否有空位（若已在Cost阶段解放了怪兽则无需重复检查）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查对方场上是否存在可作为对象的、攻击力2000以上且可被效果解放的怪兽
		return res and Duel.IsExistingTarget(c83512285.rfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 检查自己的手卡·卡组·墓地是否存在可以特殊召唤的「银河眼光子龙」
			and Duel.IsExistingMatchingCard(c83512285.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 给玩家发送提示信息：请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择对方场上1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c83512285.rfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：准备从手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果运行（Activate）处理：解放对象怪兽并特殊召唤「银河眼光子龙」
function c83512285.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其解放，并确认是否解放成功
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
		-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 给玩家发送提示信息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·卡组·墓地选择1只「银河眼光子龙」（适用王家长眠之谷的过滤判定）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c83512285.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「银河眼光子龙」在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
