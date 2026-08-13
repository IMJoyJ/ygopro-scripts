--機械天使の絶対儀式
-- 效果：
-- 「电子化天使」仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从自己墓地让天使族或者战士族的怪兽回到卡组，从手卡把1只「电子化天使」仪式怪兽仪式召唤。
function c11398951.initial_effect(c)
	-- 「电子化天使」仪式怪兽的降临必需。①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从自己墓地让天使族或者战士族的怪兽回到卡组，从手卡把1只「电子化天使」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11398951.target)
	e1:SetOperation(c11398951.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片属于「电子化天使」系列，即作为仪式召唤对象时需要满足的字段。
function c11398951.filter(c,e,tp)
	return c:IsSetCard(0x2093)
end
-- 墓地替代素材的筛选条件：等级大于0、种族为天使族或战士族、并且能够返回卡组。
function c11398951.mfilter(c)
	return c:GetLevel()>0 and c:IsRace(RACE_WARRIOR+RACE_FAIRY) and c:IsAbleToDeck()
end
-- 效果发动时的条件检查和操作信息登记：确认手牌中存在可仪式召唤的「电子化天使」怪兽，且有合法素材组合；随后登记本效果将进行特殊召唤和将墓地怪兽返回卡组的处理。
function c11398951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家tp可用的仪式召唤素材集合（包括手牌、场上可解放的怪兽以及墓地中的仪式魔人等）。
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取自己墓地中满足mfilter条件的怪兽集合，作为解放的代替素材。
		local mg2=Duel.GetMatchingGroup(c11398951.mfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查手牌中是否存在1只「电子化天使」仪式怪兽，能够使用mg1和mg2中的素材使等级合计恰好等于该怪兽等级，从而可进行仪式召唤。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c11398951.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	end
	-- 登记本效果将进行1只怪兽从手牌的特殊召唤（仪式召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 登记本效果可能将墓地中的怪兽返回卡组的操作信息（数量未知，初始设为0）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
-- 效果处理：选择要仪式召唤的「电子化天使」怪兽，选择符合等级合计的仪式素材，完成解放或代替回卡组，然后进行仪式召唤。
function c11398951.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取当前实际可用的仪式召唤素材集合，用于后续选择素材。
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取自己墓地中不受王家长眠之谷影响且满足mfilter条件的怪兽，作为解放的代替素材。
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c11398951.mfilter),tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，进入仪式怪兽的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只符合「电子化天使」字段且拥有合法素材组合的仪式怪兽作为特殊召唤对象。
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
		-- 向玩家显示“请选择要解放的卡”的提示，进入仪式素材的选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的素材合法性检查：所选素材的等级合计必须恰好等于仪式怪兽的等级，防止选择多余素材。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 从可选素材中自动选择一组等级合计恰好等于仪式怪兽等级的卡片作为本次仪式召唤的素材。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除之前设置的额外素材检查闭包，避免对后续操作产生干扰。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsRace,nil,RACE_WARRIOR+RACE_FAIRY)
		if #mat2>0 then
			-- 为将要返回卡组的墓地素材显示选中动画，并将这些卡记录为对象。
			Duel.HintSelection(mat2)
		end
		mat:Sub(mat2)
		-- 执行仪式素材的解放处理（通常为手牌/场上的怪兽；如包含墓地仪式魔人等特殊素材则除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 将作为解放代替的墓地天使族/战士族怪兽返回卡组并洗牌，原因标记为效果和仪式素材。
		Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使之后的特殊召唤视为另一次处理，以产生正确的时点。
		Duel.BreakEffect()
		-- 将选择的「电子化天使」仪式怪兽以表侧表示进行仪式召唤，并完成仪式召唤程序。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
