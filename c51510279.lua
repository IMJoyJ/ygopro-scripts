--繋がれし魔鍵
-- 效果：
-- ①：以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从以下效果选1个适用。
-- ●从自己的手卡·场上把「魔键」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组守备表示融合召唤。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「魔键」仪式怪兽守备表示仪式召唤。
function c51510279.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c51510279.target)
	e1:SetOperation(c51510279.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的通常怪兽或魔键怪兽（类型为通常怪兽或魔键怪兽且能加入手牌）
function c51510279.thfilter(c)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 效果作用：选择自己墓地满足条件的1只怪兽作为对象
function c51510279.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51510279.thfilter(chkc) end
	-- 效果作用：判断是否满足发动条件（即自己墓地是否存在满足条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c51510279.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,c51510279.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置操作信息，表示将要将该怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：判断卡片是否免疫当前效果
function c51510279.ffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：筛选满足融合召唤条件的魔键融合怪兽（类型为融合且属于魔键系列，并可特殊召唤）
function c51510279.ffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x165) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false,POS_FACEUP_DEFENSE) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数：筛选满足仪式召唤条件的魔键仪式怪兽（属于魔键系列且可特殊召唤）
function c51510279.rfilter(c,e,tp)
	return c:IsSetCard(0x165) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP_DEFENSE)
end
-- 效果作用：处理发动后的操作，包括选择融合或仪式召唤方式并执行相应召唤
function c51510279.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local th=Duel.GetFirstTarget()
	-- 效果作用：判断目标卡是否有效并将其加入手牌
	if not th:IsRelateToEffect(e) or Duel.SendtoHand(th,nil,REASON_EFFECT)==0 or not th:IsLocation(LOCATION_HAND) then return end
	local chkf=tp
	-- 效果作用：获取玩家可用的融合素材组（排除免疫效果的卡片）
	local fmg1=Duel.GetFusionMaterial(tp):Filter(c51510279.ffilter1,nil,e)
	-- 效果作用：获取满足融合召唤条件的魔键融合怪兽组
	local fsg1=Duel.GetMatchingGroup(c51510279.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,fmg1,nil,chkf)
	local fmg2=nil
	local fsg2=nil
	-- 效果作用：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		fmg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：根据连锁效果获取额外的融合怪兽组
		fsg2=Duel.GetMatchingGroup(c51510279.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,fmg2,mf,chkf)
	end
	-- 效果作用：获取玩家可用的仪式召唤素材组
	local rmg1=Duel.GetRitualMaterial(tp)
	-- 效果作用：获取满足仪式召唤条件的魔键仪式怪兽组
	local rsg=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c51510279.rfilter,e,tp,rmg1,nil,Card.GetLevel,"Greater")
	local off=1
	local ops={}
	local opval={}
	ops[off]=aux.Stringid(51510279,0)  --"什么都不做"
	opval[off-1]=0
	off=off+1
	if fsg1:GetCount()>0 or (fsg2~=nil and fsg2:GetCount()>0) then
		ops[off]=aux.Stringid(51510279,1)  --"融合召唤"
		opval[off-1]=1
		off=off+1
	end
	if rsg:GetCount()>0 then
		ops[off]=aux.Stringid(51510279,2)  --"仪式召唤"
		opval[off-1]=2
		off=off+1
	end
	-- 效果作用：让玩家选择要执行的效果（融合或仪式召唤）
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		-- 效果作用：中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		local sg=fsg1:Clone()
		if fsg2 then sg:Merge(fsg2) end
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		fmg1:RemoveCard(tc)
		-- 效果作用：判断是否使用连锁提供的融合素材组
		if fsg1:IsContains(tc) and (fsg2==nil or not fsg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,fmg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 效果作用：将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 效果作用：选择融合召唤所需的替代素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,fmg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	elseif opval[op]==2 then
		::rcancel::
		-- 效果作用：中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=rsg:Select(tp,1,1,nil):GetFirst()
		local rmg=rmg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			rmg=rmg:Filter(tc.mat_filter,tc,tp)
		else
			rmg:RemoveCard(tc)
		end
		-- 效果作用：提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 效果作用：设置仪式召唤的附加检查函数
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 效果作用：选择满足仪式召唤条件的素材组
		local mat=rmg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 效果作用：清除仪式召唤的附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto rcancel end
		tc:SetMaterial(mat)
		-- 效果作用：将仪式召唤的素材解放
		Duel.ReleaseRitualMaterial(mat)
		-- 效果作用：中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：将仪式怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_DEFENSE)
		tc:CompleteProcedure()
	end
end
