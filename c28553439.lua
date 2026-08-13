--ディメンション・マジック
-- 效果：
-- ①：自己场上有魔法师族怪兽存在的场合，以自己场上1只怪兽为对象才能发动。那只自己怪兽解放，从手卡把1只魔法师族怪兽特殊召唤。那之后，可以选场上1只怪兽破坏。
function c28553439.initial_effect(c)
	-- ①：自己场上有魔法师族怪兽存在的场合，以自己场上1只怪兽为对象才能发动。那只自己怪兽解放，从手卡把1只魔法师族怪兽特殊召唤。那之后，可以把场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c28553439.condition)
	e1:SetTarget(c28553439.target)
	e1:SetOperation(c28553439.activate)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否为表侧表示且为魔法师族，用于筛选自己场上符合条件的魔法师族怪兽。
function c28553439.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件：检查自己场上是否存在至少1只表侧表示魔法师族怪兽。
function c28553439.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体通过检索自己场上表侧表示怪兽中是否存在魔法师族怪兽来满足发动条件。
	return Duel.IsExistingMatchingCard(c28553439.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选手卡中满足“魔法师族且可以被效果特殊召唤”的怪兽，作为从手卡特殊召唤的候选。
function c28553439.filter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选可解放的怪兽：必须能成为效果对象，并且若场上没有空余怪兽区，则必须是自己场上主要怪兽区的怪兽（解放后才能空出格子用于特殊召唤）。
function c28553439.rfilter(c,e,tp,ft)
	return c:IsCanBeEffectTarget(e)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
-- 发动时的目标处理：检查是否满足发动条件（有格子、有可解放对象、手卡有可特招的魔法师族），并选择要解放的怪兽作为对象。
function c28553439.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上主要怪兽区的可用空格数，用于判断解放后能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28553439.rfilter(chkc,e,tp,ft) end
	-- 检查是否存在至少1只可作为对象解放的怪兽，且解放后能确保腾出特殊召唤所需的位置（ft>-1表示即使当前无空格，也能通过解放自己主要怪兽区的怪兽腾出格子）。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupEx(tp,c28553439.rfilter,1,REASON_EFFECT,false,nil,e,tp,ft)
		-- 检查手卡中是否有至少1只魔法师族怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c28553439.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 从符合条件的怪兽中选择1只作为解放对象（该选择即为取对象）。
	local g=Duel.SelectReleaseGroupEx(tp,c28553439.rfilter,1,1,REASON_EFFECT,false,nil,e,tp,ft)
	-- 将选中的解放对象设为这张卡的效果对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息，标明之后将进行从手卡特殊召唤1只怪兽的处理，用于发动时点的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：解放对象怪兽，从手卡特殊召唤1只魔法师族怪兽，之后任意选择场上1只怪兽破坏。
function c28553439.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（发动时选择要解放的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
		-- 解放对象怪兽；若未能成功解放则效果处理中止。
		if Duel.Release(tc,REASON_EFFECT)==0 then return end
		-- 弹出“请选择要特殊召唤的卡”的提示，用于后续从手卡选择怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只满足条件的魔法师族怪兽（魔法师族且可特殊召唤）。
		local sg=Duel.SelectMatchingCard(tp,c28553439.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if sg:GetCount()==0 then return end
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上；若特殊召唤失败则中止后续破坏处理。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 获取双方场上所有怪兽作为“那之后”可破坏的候选对象（不取对象）。
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 若场上有怪兽且玩家选择“是”，则进行后续的破坏处理。
		if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(28553439,0)) then  --"是否要破坏一只怪兽？"
			-- 弹出“请选择要破坏的卡”的提示，用于选择要破坏的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local des=dg:Select(tp,1,1,nil)
			-- 用动画展示所选破坏对象，并将其记录为当前连锁选中的卡片。
			Duel.HintSelection(des)
			-- 中断效果处理流程，使后续破坏处理与之前的特殊召唤处理分开进行，避免同时处理影响时点。
			Duel.BreakEffect()
			-- 以效果原因破坏选中的怪兽。
			Duel.Destroy(des,REASON_EFFECT)
		end
	end
end
