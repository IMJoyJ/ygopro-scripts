--繋がれし魔鍵
-- 效果：
-- ①：以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从以下效果选1个适用。
-- ●从自己的手卡·场上把「魔键」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组守备表示融合召唤。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「魔键」仪式怪兽守备表示仪式召唤。
function c51510279.initial_effect(c)
	-- ①：以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从以下效果选1个适用。 ●从自己的手卡·场上把「魔键」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组守备表示融合召唤。 ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「魔键」仪式怪兽守备表示仪式召唤。
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
-- 定义墓地对象筛选函数：目标须为通常怪兽，或为「魔键」系列怪兽，且能被加入手卡。
function c51510279.thfilter(c)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 发动时的目标选择处理：判断能否以墓地1只符合条件的通常怪兽或「魔键」怪兽为对象；若能则让玩家选择目标，并设置加入手卡的操作信息。
function c51510279.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51510279.thfilter(chkc) end
	-- 效果发动合法性检查：确认自己墓地存在至少1只满足条件的通常怪兽或「魔键」怪兽，否则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c51510279.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，要求从墓地选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的通常怪兽或「魔键」怪兽，将其作为本卡效果的对象。
	local g=Duel.SelectTarget(tp,c51510279.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本连锁的操作信息：将对象卡加入手卡，用于触发相关时点/判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤不能被效果影响的融合素材，保证素材能正常被送去墓地。
function c51510279.ffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选满足融合召唤条件的「魔键」融合怪兽：必须能用当前素材进行融合召唤，且能以表侧守备表示特殊召唤。
function c51510279.ffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x165) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false,POS_FACEUP_DEFENSE) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选满足仪式召唤条件的「魔键」仪式怪兽：必须能以表侧守备表示进行仪式召唤（不检查苏生限制）。
function c51510279.rfilter(c,e,tp)
	return c:IsSetCard(0x165) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP_DEFENSE)
end
-- 效果处理：先将对象卡加入手卡，若成功则让玩家选择适用融合召唤或仪式召唤，并执行对应的召唤处理。
function c51510279.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡（墓地的那只怪兽）。
	local th=Duel.GetFirstTarget()
	-- 若对象卡已不与该效果关联，或送入/加入手卡失败，或不在手卡，则终止后续处理。
	if not th:IsRelateToEffect(e) or Duel.SendtoHand(th,nil,REASON_EFFECT)==0 or not th:IsLocation(LOCATION_HAND) then return end
	local chkf=tp
	-- 获取当前可用的融合素材，并排除对效果免疫的卡，作为常规融合候选素材。
	local fmg1=Duel.GetFusionMaterial(tp):Filter(c51510279.ffilter1,nil,e)
	-- 从额外卡组筛选能用常规融合素材进行守备表示融合召唤的「魔键」融合怪兽。
	local fsg1=Duel.GetMatchingGroup(c51510279.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,fmg1,nil,chkf)
	local fmg2=nil
	local fsg2=nil
	-- 获取当前玩家可用的连锁素材效果（如代替融合素材的效果），以便扩展融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		fmg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则使用其提供的额外素材，再次筛选可融合召唤的「魔键」融合怪兽。
		fsg2=Duel.GetMatchingGroup(c51510279.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,fmg2,mf,chkf)
	end
	-- 获取当前可用的仪式召唤素材（手卡·场上可解放的怪兽及特殊素材）。
	local rmg1=Duel.GetRitualMaterial(tp)
	-- 从手卡筛选能够用上述仪式素材进行仪式召唤的「魔键」仪式怪兽，要求素材等级合计达到该怪兽等级以上。
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
	-- 让玩家从「什么都不做」「融合召唤」「仪式召唤」中选择一项适用的后续效果。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		-- 中断当前效果处理，使后续的融合召唤作为独立处理进行，避免与其他处理同时进行而错过时点。
		Duel.BreakEffect()
		local sg=fsg1:Clone()
		if fsg2 then sg:Merge(fsg2) end
		-- 向玩家显示选择提示，要求选择要融合召唤的「魔键」融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		fmg1:RemoveCard(tc)
		-- 判断所选融合怪兽是否使用常规素材分支：若它不在连锁素材候选中，或玩家选择不使用连锁素材，则按常规融合处理；否则进入连锁素材分支。
		if fsg1:IsContains(tc) and (fsg2==nil or not fsg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规融合素材中选择符合所选融合怪兽融合召唤条件的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,fmg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材按效果·素材·融合召唤的原因送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后的融合召唤作为独立处理进行。
			Duel.BreakEffect()
			-- 将所选「魔键」融合怪兽以表侧守备表示进行融合召唤到自己的怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 在连锁素材分支中，让玩家从连锁素材效果提供的素材中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,fmg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	elseif opval[op]==2 then
		::rcancel::
		-- 中断当前效果处理，使后续的仪式召唤作为独立处理进行。
		Duel.BreakEffect()
		-- 向玩家显示选择提示，要求选择要仪式召唤的「魔键」仪式怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=rsg:Select(tp,1,1,nil):GetFirst()
		local rmg=rmg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			rmg=rmg:Filter(tc.mat_filter,tc,tp)
		else
			rmg:RemoveCard(tc)
		end
		-- 向玩家显示选择提示，要求选择要解放作为仪式素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式素材等级检查规则：允许素材等级合计大于等于仪式怪兽等级，并防止选择多余素材。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家从可用仪式素材中选择等级合计达到要求的一组怪兽，作为仪式召唤的解放素材。
		local mat=rmg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除此前设置的额外素材检查函数，避免影响后续效果处理。
		aux.GCheckAdditional=nil
		if not mat then goto rcancel end
		tc:SetMaterial(mat)
		-- 将选定的仪式素材解放（若为墓地的特殊素材则除外），完成仪式召唤的素材支付。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使随后的仪式召唤作为独立处理进行。
		Duel.BreakEffect()
		-- 将所选「魔键」仪式怪兽以表侧守备表示进行仪式召唤到自己的怪兽区。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_DEFENSE)
		tc:CompleteProcedure()
	end
end
