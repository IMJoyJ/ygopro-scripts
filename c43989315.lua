--召喚獣ソラト
-- 效果：
-- 「阿莱斯特」怪兽＋炎·风属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己或对方的墓地1只6星以下的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡在墓地存在的场合才能发动。包含墓地的这张卡的自己的场上·墓地的怪兽作为融合素材除外，把1只「召唤兽」融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果主函数，注册融合素材手续、主要阶段特召墓地怪兽且效果无效的二速效果，以及墓地起动除外素材融合召唤「召唤兽」融合怪兽的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册融合召唤素材手续：需要1只「阿莱斯特」怪兽和1只炎·风属性怪兽作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1e1),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_FIRE+ATTRIBUTE_WIND),true)
	-- 自己·对方的主要阶段，以自己或对方的墓地1只6星以下的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在的场合才能发动。包含墓地的这张卡的自己的场上·墓地的怪兽作为融合素材除外，把1只「召唤兽」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
-- 特召效果的触发条件：必须在自己或对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前阶段为主要阶段（主要阶段1或主要阶段2）。
	return Duel.IsMainPhase()
end
-- 墓地特召怪兽过滤条件：等级在6星以下，且在当前情况下可以以守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特召效果的Target函数：确认主要怪兽区域有空位且自己或对方墓地存在符合条件的怪兽，作为效果的目标，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 效果发动时的合法性检查：检查自己场上的主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查双方墓地中是否存在至少1只可以特殊召唤的6星以下怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1只满足条件的6星以下怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息：预计将所选择的目标墓地怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特召效果的Operation函数：将选定的墓地怪兽守备表示特殊召唤，并注册使其效果无效的单体永续效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选为效果对象的怪兽卡。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否依然对应当前连锁，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 并且尝试将其以表侧守备表示在特殊召唤步骤中召唤。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成所有特殊召唤步骤的后续处理。
	Duel.SpecialSummonComplete()
end
-- 融合素材过滤辅助函数：确认卡片在场上且不免疫此效果。
function s.cfilter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 墓地融合素材过滤条件：是怪兽卡、可以作为融合素材、可以被除外且不免疫此效果。
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽合法性过滤条件：是融合怪兽、属于「召唤兽」系列、符合融合怪兽原本要求的特殊融合条件，能够被特殊召唤，且可以使用选定的素材进行融合召唤。
function s.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 融合效果的Target函数：计算融合可用的素材并检查额外卡组是否存在符合条件的「召唤兽」融合怪兽，设置特殊召唤和除外素材的操作信息。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己场上和手牌中不受影响的可用融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.cfilter1,nil,e)
		-- 获取自己墓地中满足除外融合素材条件的怪兽。
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在包含此卡自身作为素材能够融合召唤的「召唤兽」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁融合素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁融合效果存在时，使用连锁融合对应的素材组再次检查是否存在能够融出的「召唤兽」怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤操作信息：预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外操作信息：预计将墓地中的此卡自身除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,LOCATION_GRAVE)
end
-- 融合效果的Operation函数：融合召唤1只「召唤兽」融合怪兽，将其融合素材（包括此卡自身）从场上或墓地除外。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 重新获取自己场上和手牌中不受影响的可用融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.cfilter1,nil,e)
	-- 重新获取不受王家长眠之谷影响的自己墓地中满足除外融合素材条件的怪兽。
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 获取此时额外卡组中可以使用获取的素材融合召唤出的所有「召唤兽」融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 重新获取连锁融合效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以使用特殊融合素材组融合召唤出的「召唤兽」融合怪兽。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选定的融合怪兽是否可以通过常规除外场上/墓地素材的方式来进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用的场上/手牌/墓地素材中选择融合召唤目标怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材以表侧表示除外。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤处理不与除外素材视为同时进行。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示融合召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在使用连锁融合效果时，让玩家从连锁素材中选择融合所需的素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
