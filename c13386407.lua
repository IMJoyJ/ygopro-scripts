--ラヴェナス・ヴェンデット
-- 效果：
-- 「复仇死者」仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·卡组·墓地选「复仇死者·噬腐鬼」以外的1只「复仇死者」怪兽里侧守备表示特殊召唤。那之后，以下效果适用。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含这个效果特殊召唤的怪兽的自己场上的怪兽解放，从自己的手卡·墓地把1只「复仇死者」仪式怪兽仪式召唤。
function c13386407.initial_effect(c)
	-- 登记本卡效果文本中记载的卡名「复仇死者·噬腐鬼」（卡号29348048），以便系统能识别该卡名参照。
	aux.AddCodeList(c,29348048)
	-- 「复仇死者」仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。①：从自己的手卡·卡组·墓地选「复仇死者·噬腐鬼」以外的1只「复仇死者」怪兽里侧守备表示特殊召唤。那之后，以下效果适用。●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含这个效果特殊召唤的怪兽的自己场上的怪兽解放，从自己的手卡·墓地把1只「复仇死者」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13386407+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c13386407.target)
	e1:SetOperation(c13386407.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：筛选出持有「复仇死者」字段（0x106）的怪兽。
function c13386407.filter(c)
	return c:IsSetCard(0x106)
end
-- 定义仪式召唤目标的最终过滤器：判断候选卡是否为「复仇死者」仪式怪兽、能否被仪式召唤，并检查以特殊召唤怪兽mc为必要素材时，是否存在等级合计满足条件的合法解放组合。
function c13386407.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk,mc)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	-- 设置额外的仪式素材检查函数，使接下来的素材组选择必须满足等级合计大于等于指定等级，并避免选择多余素材。
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(c13386407.rcheck,1,lv,tp,c,lv,greater_or_equal,mc)
	-- 清除额外检查函数，避免影响后续其他选择或检索操作。
	aux.GCheckAdditional=nil
	return res
end
-- 定义解放素材子组的校验函数：确认所选素材组能作为该仪式怪兽的合法仪式素材，并且必须包含指定怪兽mc。
function c13386407.rcheck(g,tp,c,lv,greater_or_equal,mc)
	-- 返回“该素材组满足仪式召唤条件”且“素材组中包含指定怪兽mc”的判定结果。
	return aux.RitualCheck(g,tp,c,lv,greater_or_equal) and g:IsContains(mc)
end
-- 定义特殊召唤候选怪兽的过滤器：要求是「复仇死者」字段且不是「复仇死者·噬腐鬼」，能以里侧守备表示特殊召唤，并存在可将其作为素材进行后续仪式召唤的目标。
function c13386407.spfilter(c,e,tp)
	if not (c:IsSetCard(0x106) and not c:IsCode(29348048)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)) then return false end
	-- 取得当前可用的仪式素材，并只保留自己场上主要怪兽区的卡，作为后续解放素材的候选组。
	local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	mg:AddCard(c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 把包含这个效果特殊召唤的怪兽的自己场上的怪兽解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		-- 检查手卡或墓地是否存在1只「复仇死者」仪式怪兽，能够以包含候选怪兽c在内的素材进行等级达标的仪式召唤。
		local res=Duel.IsExistingMatchingCard(c13386407.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c13386407.filter,e,tp,mg,nil,Card.GetLevel,"Greater",true,c)
		e1:Reset()
		return res
	else
		-- 返回是否存在上述可行仪式召唤目标（供spfilter最终判定）。
		return Duel.IsExistingMatchingCard(c13386407.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c13386407.filter,e,tp,mg,nil,Card.GetLevel,"Greater",true,c)
	end
end
-- 定义效果发动时的合法性检测：确认己方主要怪兽区有空位、存在可特殊召唤的「复仇死者」候选怪兽，且本回合还能进行两次特殊召唤。
function c13386407.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时要求己方主要怪兽区存在可用空格，以便放置后续特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时要求手卡·卡组·墓地存在满足条件且能支持后续仪式召唤的特殊召唤候选怪兽。
		and Duel.IsExistingMatchingCard(c13386407.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且本回合剩余特殊召唤次数至少为2（一次用于特殊召唤，一次用于仪式召唤）。
		and Duel.IsPlayerCanSpecialSummonCount(tp,2) end
	-- 登记本次效果的操作为：从手卡·卡组·墓地进行的1次特殊召唤，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义效果处理流程：先选1只符合条件的「复仇死者」怪兽里侧守备特殊召唤并向对方确认；再以包含该怪兽的己方场上怪兽为素材，从手卡·墓地仪式召唤1只「复仇死者」仪式怪兽。
function c13386407.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时若己方主要怪兽区没有空位，则整个效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家正在选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组·墓地选择1张满足条件的「复仇死者」怪兽作为要特殊召唤的卡，并取为sc。
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13386407.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 若成功将sc以里侧守备表示特殊召唤到自己场上，则继续执行后续的仪式召唤处理。
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 将里侧守备表示特殊召唤的sc给对方玩家确认。
		Duel.ConfirmCards(1-tp,sc)
		::cancel::
		-- 重新取得当前可用于仪式解放的己方场上主要怪兽区素材组mg。
		local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
		-- 提示玩家正在选择要仪式召唤的怪兽（显示“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·墓地选择1只符合条件的「复仇死者」仪式怪兽作为仪式召唤对象，并校验能使用包含sc在内的素材完成仪式召唤。
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13386407.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c13386407.filter,e,tp,mg,nil,Card.GetLevel,"Greater",true,sc)
		local tc=tg:GetFirst()
		local mat
		if tc then
			-- 中断当前效果，使后续处理与之前的特殊召唤错开时点（避免错过时点）。
			Duel.BreakEffect()
			mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			-- 提示玩家选择要解放的卡（显示“请选择要解放的卡”）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			local lv=Card.GetLevel(tc)
			-- 设置额外的等级检查，要求所选祭品的等级合计大于等于仪式怪兽tc的等级。
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,lv,"Greater")
			mat=mg:SelectSubGroup(tp,c13386407.rcheck,true,1,lv,tp,tc,lv,"Greater",sc)
			-- 清除额外的等级检查，防止影响后续操作。
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 将选中的仪式素材解放（若素材来自墓地中的仪式魔人等特殊素材，则除外）。
			Duel.ReleaseRitualMaterial(mat)
			-- 中断效果，使随后的仪式召唤作为新的特殊召唤时点处理（与解放素材错开时点）。
			Duel.BreakEffect()
			-- 以仪式召唤方式（SUMMON_TYPE_RITUAL）将tc表侧表示特殊召唤到自己场上，不检查苏生限制。
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
