--ラヴェナス・ヴェンデット
-- 效果：
-- 「复仇死者」仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·卡组·墓地选「复仇死者·噬腐鬼」以外的1只「复仇死者」怪兽里侧守备表示特殊召唤。那之后，以下效果适用。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含这个效果特殊召唤的怪兽的自己场上的怪兽解放，从自己的手卡·墓地把1只「复仇死者」仪式怪兽仪式召唤。
function c13386407.initial_effect(c)
	-- 为卡片注册关联卡片代码，标明该卡效果中提及了「复仇死者·噬腐鬼」（代码29348048）
	aux.AddCodeList(c,29348048)
	-- ①：从自己的手卡·卡组·墓地选「复仇死者·噬腐鬼」以外的1只「复仇死者」怪兽里侧守备表示特殊召唤。那之后，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13386407+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c13386407.target)
	e1:SetOperation(c13386407.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选「复仇死者」卡组
function c13386407.filter(c)
	return c:IsSetCard(0x106)
end
-- 仪式最终过滤函数，用于判断是否可以作为仪式召唤的祭品
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
	-- 设置全局附加检查函数，用于验证仪式召唤的等级条件
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(c13386407.rcheck,1,lv,tp,c,lv,greater_or_equal,mc)
	-- 清除全局附加检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 用于检查祭品组合是否满足仪式召唤条件的辅助函数
function c13386407.rcheck(g,tp,c,lv,greater_or_equal,mc)
	-- 返回仪式召唤检查结果并确保包含特殊召唤的怪兽
	return aux.RitualCheck(g,tp,c,lv,greater_or_equal) and g:IsContains(mc)
end
-- 特殊召唤过滤函数，用于筛选可特殊召唤的「复仇死者」怪兽
function c13386407.spfilter(c,e,tp)
	if not (c:IsSetCard(0x106) and not c:IsCode(29348048)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)) then return false end
	-- 获取玩家可用的仪式召唤素材组，包含场上可解放的怪兽
	local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	mg:AddCard(c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 为卡片注册额外的仪式召唤素材，使其在墓地中可作为仪式祭品
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		-- 检查是否存在满足仪式召唤条件的「复仇死者」仪式怪兽
		local res=Duel.IsExistingMatchingCard(c13386407.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c13386407.filter,e,tp,mg,nil,Card.GetLevel,"Greater",true,c)
		e1:Reset()
		return res
	else
		-- 检查是否存在满足仪式召唤条件的「复仇死者」仪式怪兽
		return Duel.IsExistingMatchingCard(c13386407.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c13386407.filter,e,tp,mg,nil,Card.GetLevel,"Greater",true,c)
	end
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c13386407.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌、卡组、墓地中是否存在可特殊召唤的「复仇死者」怪兽
		and Duel.IsExistingMatchingCard(c13386407.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查玩家是否可以进行两次特殊召唤
		and Duel.IsPlayerCanSpecialSummonCount(tp,2) end
	-- 设置连锁操作信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动时的处理函数，用于执行效果内容
function c13386407.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「复仇死者」怪兽进行特殊召唤
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13386407.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 执行特殊召唤操作，将选中的怪兽以里侧守备表示特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,sc)
		::cancel::
		-- 获取玩家可用的仪式召唤素材组，包含场上可解放的怪兽
		local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
		-- 提示玩家选择要仪式召唤的「复仇死者」仪式怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的「复仇死者」仪式怪兽进行仪式召唤
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13386407.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c13386407.filter,e,tp,mg,nil,Card.GetLevel,"Greater",true,sc)
		local tc=tg:GetFirst()
		local mat
		if tc then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			-- 提示玩家选择要解放的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local lv=Card.GetLevel(tc)
			-- 设置全局附加检查函数，用于验证仪式召唤的等级条件
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,lv,"Greater")
			mat=mg:SelectSubGroup(tp,c13386407.rcheck,true,1,lv,tp,tc,lv,"Greater",sc)
			-- 清除全局附加检查函数
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 解放选中的仪式召唤祭品
			Duel.ReleaseRitualMaterial(mat)
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 将选中的仪式怪兽以仪式召唤方式特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
