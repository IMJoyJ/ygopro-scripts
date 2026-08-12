--機械天使の絶対儀式
-- 效果：
-- 「电子化天使」仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从自己墓地让天使族或者战士族的怪兽回到卡组，从手卡把1只「电子化天使」仪式怪兽仪式召唤。
function c11398951.initial_effect(c)
	-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从自己墓地让天使族或者战士族的怪兽回到卡组，从手卡把1只「电子化天使」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11398951.target)
	e1:SetOperation(c11398951.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡片是否为「电子化天使」系列
function c11398951.filter(c,e,tp)
	return c:IsSetCard(0x2093)
end
-- 过滤函数，用于判断卡片是否为战士族或天使族且可以送回卡组
function c11398951.mfilter(c)
	return c:GetLevel()>0 and c:IsRace(RACE_WARRIOR+RACE_FAIRY) and c:IsAbleToDeck()
end
-- 效果的发动时点处理函数，用于判断是否可以发动此效果
function c11398951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家当前可用的用于仪式召唤的素材卡片组（手牌和场上的怪兽）
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取玩家墓地中满足条件的战士族或天使族怪兽组（可送回卡组）
		local mg2=Duel.GetMatchingGroup(c11398951.mfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查是否存在满足条件的「电子化天使」仪式怪兽，且其召唤所需等级合计满足要求
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c11398951.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理时将要送回卡组的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
-- 效果的发动处理函数，用于执行仪式召唤的具体操作
function c11398951.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家当前可用的用于仪式召唤的素材卡片组（手牌和场上的怪兽）
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取玩家墓地中满足条件的战士族或天使族怪兽组（可送回卡组），并排除受王家长眠之谷影响的卡
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c11398951.mfilter),tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「电子化天使」仪式怪兽进行仪式召唤
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c11398951.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择用于解放的素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		-- 设置仪式召唤的等级检查附加条件，确保等级合计等于目标等级
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 从可用素材中选择满足等级要求的子集作为仪式召唤的素材
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除附加的等级检查条件
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsRace,nil,RACE_WARRIOR+RACE_FAIRY)
		if #mat2>0 then
			-- 显示被选为仪式召唤素材的墓地怪兽动画效果
			Duel.HintSelection(mat2)
		end
		mat:Sub(mat2)
		-- 解放选中的仪式召唤素材
		Duel.ReleaseRitualMaterial(mat)
		-- 将作为替代解放的墓地怪兽送回卡组
		Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 将选中的仪式怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
