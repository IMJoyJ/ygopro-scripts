--ディメンション・マジック
-- 效果：
-- ①：自己场上有魔法师族怪兽存在的场合，以自己场上1只怪兽为对象才能发动。那只自己怪兽解放，从手卡把1只魔法师族怪兽特殊召唤。那之后，可以选场上1只怪兽破坏。
function c28553439.initial_effect(c)
	-- 效果原文内容：①：自己场上有魔法师族怪兽存在的场合，以自己场上1只怪兽为对象才能发动。
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
-- 效果作用：过滤场上存在的魔法师族怪兽
function c28553439.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果作用：检查自己场上是否存在魔法师族怪兽
function c28553439.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否存在魔法师族怪兽
	return Duel.IsExistingMatchingCard(c28553439.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：过滤手卡中可以特殊召唤的魔法师族怪兽
function c28553439.filter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：过滤可以被选为解放对象的怪兽
function c28553439.rfilter(c,e,tp,ft)
	return c:IsCanBeEffectTarget(e)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
-- 效果作用：设置效果目标并检查是否满足发动条件
function c28553439.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果作用：获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28553439.rfilter(chkc,e,tp,ft) end
	-- 效果作用：检查是否满足解放怪兽的条件
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupEx(tp,c28553439.rfilter,1,REASON_EFFECT,false,nil,e,tp,ft)
		-- 效果作用：检查手卡中是否存在魔法师族怪兽
		and Duel.IsExistingMatchingCard(c28553439.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,c28553439.rfilter,1,1,REASON_EFFECT,false,nil,e,tp,ft)
	-- 效果作用：将选中的怪兽设置为效果对象
	Duel.SetTargetCard(g)
	-- 效果作用：设置操作信息，表示将要特殊召唤魔法师族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果原文内容：那只自己怪兽解放，从手卡把1只魔法师族怪兽特殊召唤。那之后，可以选场上1只怪兽破坏。
function c28553439.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
		-- 效果作用：解放目标怪兽
		if Duel.Release(tc,REASON_EFFECT)==0 then return end
		-- 效果作用：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 效果作用：从手卡中选择魔法师族怪兽进行特殊召唤
		local sg=Duel.SelectMatchingCard(tp,c28553439.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if sg:GetCount()==0 then return end
		-- 效果作用：将选中的魔法师族怪兽特殊召唤到场上
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 效果作用：获取场上所有怪兽
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 效果作用：询问玩家是否要破坏场上怪兽
		if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(28553439,0)) then  --"是否要破坏一只怪兽？"
			-- 效果作用：提示玩家选择要破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local des=dg:Select(tp,1,1,nil)
			-- 效果作用：显示被选中的怪兽作为破坏对象
			Duel.HintSelection(des)
			-- 效果作用：中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 效果作用：破坏选中的怪兽
			Duel.Destroy(des,REASON_EFFECT)
		end
	end
end
