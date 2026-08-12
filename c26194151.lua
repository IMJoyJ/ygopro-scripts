--ネクロイド・シンクロ
-- 效果：
-- ①：调整1只和调整以外的怪兽最多2只从自己墓地除外，把持有和除外的怪兽的等级合计相同等级的1只「星尘」同调怪兽从额外卡组当作同调召唤作特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c26194151.initial_effect(c)
	-- ①：调整1只和调整以外的怪兽最多2只从自己墓地除外，把持有和除外的怪兽的等级合计相同等级的1只「星尘」同调怪兽从额外卡组当作同调召唤作特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26194151.target)
	e1:SetOperation(c26194151.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查满足条件的「星尘」同调怪兽，包括：属于星尘卡组、类型为同调、可以被特殊召唤、场上空位足够、且在墓地存在满足条件的调整和非调整怪兽组合。
function c26194151.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO)
		-- 检查目标怪兽是否可以被特殊召唤为同调怪兽，并且场上是否有足够的空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 检查在墓地中是否存在满足条件的调整和非调整怪兽组合，用于构成同调召唤的素材。
		and Duel.IsExistingMatchingCard(c26194151.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,lv)
end
-- 过滤函数，检查满足条件的调整怪兽，包括：类型为调整、可以除外、且其等级差值范围内存在满足等级和要求的非调整怪兽组合。
function c26194151.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	-- 获取墓地中所有非调整且可除外的怪兽集合。
	local rg=Duel.GetMatchingGroup(c26194151.filter3,tp,LOCATION_GRAVE,0,c)
	return rlv>0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		and rg:CheckWithSumEqual(Card.GetLevel,rlv,1,2)
end
-- 过滤函数，检查满足条件的非调整怪兽，包括：等级大于0、类型不是调整、可以除外。
function c26194151.filter3(c)
	return c:GetLevel()>0 and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
-- 判断是否满足发动条件，包括：必须有同调素材、额外卡组存在满足条件的「星尘」同调怪兽。
function c26194151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即是否满足必须成为同调素材的条件。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在满足条件的「星尘」同调怪兽。
		and Duel.IsExistingMatchingCard(c26194151.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果的处理函数，包括选择要特殊召唤的怪兽、选择要除外的怪兽、执行除外操作、特殊召唤怪兽并设置效果无效。
function c26194151.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查是否满足发动条件，即是否满足必须成为同调素材的条件。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「星尘」同调怪兽。
	local g1=Duel.SelectMatchingCard(tp,c26194151.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	if tc then
		local lv=tc:GetLevel()
		-- 提示玩家选择要除外的调整怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的调整怪兽。
		local g2=Duel.SelectMatchingCard(tp,c26194151.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp,lv)
		local rlv=lv-g2:GetFirst():GetLevel()
		-- 获取墓地中所有非调整且可除外的怪兽集合。
		local rg=Duel.GetMatchingGroup(c26194151.filter3,tp,LOCATION_GRAVE,0,g2:GetFirst())
		-- 提示玩家选择要除外的非调整怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,2)
		g2:Merge(g3)
		-- 将选中的怪兽除外。
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		tc:SetMaterial(nil)
		-- 将选中的怪兽特殊召唤。
		Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		-- 特殊召唤的怪兽效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 特殊召唤的怪兽效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:CompleteProcedure()
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
