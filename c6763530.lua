--烙印追放
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「死狱乡」怪兽或者8星以上的融合怪兽为对象才能发动。那只怪兽特殊召唤。那之后，以下效果可以适用。
-- ●自己·对方场上的怪兽作为融合素材除外，把1只8星以上的融合怪兽融合召唤。
function c6763530.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「死狱乡」怪兽或者8星以上的融合怪兽为对象才能发动。那只怪兽特殊召唤。那之后，以下效果可以适用。●自己·对方场上的怪兽作为融合素材除外，把1只8星以上的融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,6763530+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c6763530.target)
	e1:SetOperation(c6763530.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中满足条件的「死狱乡」怪兽或8星以上的融合怪兽
function c6763530.filter(c,e,tp)
	return (c:IsSetCard(0x164) or c:IsType(TYPE_FUSION) and c:IsLevelAbove(8)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测
function c6763530.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c6763530.filter(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己墓地是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c6763530.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6763530.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤自己场上可以作为融合素材且能被除外的怪兽
function c6763530.filter0(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤对方场上表侧表示、可以作为融合素材且能被除外的怪兽
function c6763530.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的8星以上的融合怪兽
function c6763530.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理的核心逻辑（特殊召唤及后续的融合召唤处理）
function c6763530.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其在自己场上表侧表示特殊召唤，并确认特殊召唤成功
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE) then
		local chkf=tp
		-- 获取自己场上可用于融合召唤且能被除外的怪兽作为融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(c6763530.filter0,nil,e)
		-- 获取对方场上表侧表示、可用于融合召唤且能被除外的怪兽作为融合素材
		local mg2=Duel.GetMatchingGroup(c6763530.filter1,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 获取额外卡组中，使用当前场上素材可以融合召唤的8星以上融合怪兽
		local sg1=Duel.GetMatchingGroup(c6763530.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg3=nil
		local sg2=nil
		-- 检查是否存在受「连锁素材」等效果影响的融合召唤情况
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg3=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取在「连锁素材」等效果影响下可以融合召唤的8星以上融合怪兽
			sg2=Duel.GetMatchingGroup(c6763530.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
		end
		-- 若存在可融合召唤的怪兽，询问玩家是否适用融合召唤效果
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(6763530,0)) then  --"是否融合召唤？"
			-- 中断当前效果处理，使后续的融合召唤与特殊召唤不视为同时处理
			Duel.BreakEffect()
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要融合召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用常规融合方式（而非「连锁素材」等效果）进行融合召唤
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从自己和对方场上的素材中选择融合怪兽所需的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选择的融合素材因效果、素材、融合原因除外
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使融合素材除外与融合怪兽特殊召唤不视为同时处理
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤的方式特殊召唤到场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 在「连锁素材」等效果适用下，选择融合怪兽所需的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
