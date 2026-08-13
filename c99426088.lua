--魔鍵－マフテア
-- 效果：
-- ①：「魔键」融合怪兽卡决定的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。或者，等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「魔键」仪式怪兽仪式召唤。自己场上有通常怪兽存在的场合，也能作为融合素材怪兽或者要为仪式召唤而解放的怪兽来把卡组1只通常怪兽送去墓地。
function c99426088.initial_effect(c)
	-- ①：「魔键」融合怪兽卡决定的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。或者，等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「魔键」仪式怪兽仪式召唤。自己场上有通常怪兽存在的场合，也能作为融合素材怪兽或者要为仪式召唤而解放的怪兽来把卡组1只通常怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99426088.target)
	e1:SetOperation(c99426088.activate)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否为表侧表示的通常怪兽，用于确定是否满足“自己场上有通常怪兽存在”的条件。
function c99426088.exconfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 检查自己场上是否存在至少1只表侧表示的通常怪兽，以决定是否允许将卡组中的通常怪兽作为融合素材或仪式解放的代用素材。
function c99426088.excon(tp)
	-- 检查自己场上是否存在表侧表示的通常怪兽（作为追加使用卡组通常怪兽的前提条件）。
	return Duel.IsExistingMatchingCard(c99426088.exconfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断怪兽是否不受本卡效果影响，用于从可用融合素材中排除不能使用的怪兽。
function c99426088.ffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中可作为融合召唤对象的「魔键」融合怪兽，并确认当前可用素材组能满足其融合素材要求。
function c99426088.ffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x165) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选卡组中可作为额外融合素材的通常怪兽：必须是通常怪兽、可作为融合素材且能送去墓地。
function c99426088.fexfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 筛选手牌中可作为仪式召唤对象的「魔键」仪式怪兽。
function c99426088.rfilter(c,e,tp)
	return c:IsSetCard(0x165)
end
-- 筛选卡组中可作为仪式召唤追加素材的通常怪兽：必须是等级1以上、可作为素材且能送去墓地的通常怪兽。
function c99426088.rexfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
-- 限制素材组中来自卡组的卡数量不得超过1张（用于融合素材或仪式素材的追加通常怪兽）。
function c99426088.frcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 通用素材组检查：限制来自卡组的追加通常怪兽最多1张。
function c99426088.gcheck(sg,ec)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 效果发动条件判定：检查能否用当前素材进行「魔键」融合召唤或仪式召唤；若场上有表侧通常怪兽，可将卡组中符合条件的通常怪兽加入素材候选，但该追加素材最多1张；存在任意合法候选时效果可发动。
function c99426088.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用于融合召唤的素材组（包括手卡·场上怪兽及额外融合素材效果提供的卡）。
		local fmg1=Duel.GetFusionMaterial(tp)
		if c99426088.excon(tp) then
			-- 从卡组中获取可作为融合素材的通常怪兽集合（仅在满足场上有表侧通常怪兽时才执行）。
			local fmg2=Duel.GetMatchingGroup(c99426088.fexfilter,tp,LOCATION_DECK,0,nil)
			if fmg2:GetCount()>0 then
				fmg1:Merge(fmg2)
				-- 设置融合素材组的额外限制：来自卡组的素材最多只能有1张。
				aux.FCheckAdditional=c99426088.frcheck
				-- 设置通用素材组的额外限制：来自卡组的素材最多只能有1张。
				aux.GCheckAdditional=c99426088.gcheck
			end
		end
		-- 检查额外卡组中是否存在能用当前素材组融合召唤的「魔键」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c99426088.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,fmg1,nil,chkf)
		-- 清除融合素材的卡组数量限制（本次检查结束）。
		aux.FCheckAdditional=nil
		-- 清除通用素材的卡组数量限制。
		aux.GCheckAdditional=nil
		if not res then
			-- 获取连锁素材效果，以判断能否使用连锁素材提供的额外融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local fmg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组，检查额外卡组中是否存在可融合召唤的「魔键」融合怪兽。
				res=Duel.IsExistingMatchingCard(c99426088.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,fmg3,mf,chkf)
			end
		end
		if not res then
			-- 获取自己可用于仪式召唤的素材组（包含手卡·场上可解放的怪兽及墓地仪式魔人等）。
			local rmg1=Duel.GetRitualMaterial(tp)
			local rmg2
			if c99426088.excon(tp) then
				-- 从卡组中获取可作为仪式召唤解放素材的通常怪兽集合（仅在满足场上有表侧通常怪兽时才执行）。
				rmg2=Duel.GetMatchingGroup(c99426088.rexfilter,tp,LOCATION_DECK,0,nil)
			end
			-- 设置仪式素材组的额外限制：来自卡组的素材最多只能有1张。
			aux.RCheckAdditional=c99426088.frcheck
			-- 设置仪式素材通用检查的额外限制：来自卡组的素材最多只能有1张。
			aux.RGCheckAdditional=c99426088.gcheck
			-- 检查手牌中是否存在可用当前素材组进行仪式召唤的「魔键」仪式怪兽（等级合计大于等于该怪兽等级）。
			res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c99426088.rfilter,e,tp,rmg1,rmg2,Card.GetLevel,"Greater")
			-- 清除仪式素材的卡组数量限制。
			aux.RCheckAdditional=nil
			-- 清除仪式素材通用检查的卡组数量限制。
			aux.RGCheckAdditional=nil
		end
		return res
	end
	-- 设置本效果的操作信息为进行1次特殊召唤，对象可能来自手牌（仪式）或额外卡组（融合）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果处理：根据玩家选择执行融合召唤或仪式召唤。收集并过滤素材（场上有表侧通常怪兽时可加入卡组通常怪兽，且该追加素材最多1张）；融合召唤时将素材送去墓地后特殊召唤融合怪兽；仪式召唤时以解放/送墓素材后特殊召唤仪式怪兽，若素材选择不合法则重新选择。
function c99426088.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材组，并排除不受本卡效果影响的怪兽。
	local fmg1=Duel.GetFusionMaterial(tp):Filter(c99426088.ffilter1,nil,e)
	local exmat=false
	if c99426088.excon(tp) then
		-- 从卡组中获取可作为融合素材的通常怪兽集合（仅在场上存在表侧通常怪兽时）。
		local fmg2=Duel.GetMatchingGroup(c99426088.fexfilter,tp,LOCATION_DECK,0,nil)
		if fmg2:GetCount()>0 then
			fmg1:Merge(fmg2)
			exmat=true
		end
	end
	if exmat then
		-- 处理融合召唤前，设置融合素材中来自卡组的卡最多1张的限制。
		aux.FCheckAdditional=c99426088.frcheck
		-- 处理融合召唤前，设置通用素材中来自卡组的卡最多1张的限制。
		aux.GCheckAdditional=c99426088.gcheck
	end
	-- 选出在当前可用素材组下可融合召唤的「魔键」融合怪兽候选。
	local fsg1=Duel.GetMatchingGroup(c99426088.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,fmg1,nil,chkf)
	-- 清除融合素材限制。
	aux.FCheckAdditional=nil
	-- 清除通用素材限制。
	aux.GCheckAdditional=nil
	local fmg3=nil
	local fsg2=nil
	-- 获取连锁素材效果，以判断能否使用连锁素材提供的额外融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		fmg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组，选出可融合召唤的「魔键」融合怪兽候选。
		fsg2=Duel.GetMatchingGroup(c99426088.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,fmg3,mf,chkf)
	end
	-- 获取可用于仪式召唤的素材组（手卡·场上及墓地仪式魔人等）。
	local rmg1=Duel.GetRitualMaterial(tp)
	local rmg2
	if c99426088.excon(tp) then
		-- 从卡组中获取可作为仪式解放素材的通常怪兽集合（仅在场上存在表侧通常怪兽时）。
		rmg2=Duel.GetMatchingGroup(c99426088.rexfilter,tp,LOCATION_DECK,0,nil)
	end
	-- 设置仪式素材中来自卡组的卡最多1张的限制。
	aux.RCheckAdditional=c99426088.frcheck
	-- 设置仪式素材通用检查中来自卡组的卡最多1张的限制。
	aux.RGCheckAdditional=c99426088.gcheck
	-- 选出在当前可用素材组下可仪式召唤的「魔键」仪式怪兽候选。
	local rsg=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c99426088.rfilter,e,tp,rmg1,rmg2,Card.GetLevel,"Greater")
	-- 清除仪式素材限制。
	aux.RCheckAdditional=nil
	-- 清除仪式素材通用限制。
	aux.RGCheckAdditional=nil
	local off=1
	local ops={}
	local opval={}
	if fsg1:GetCount()>0 or (fsg2~=nil and fsg2:GetCount()>0) then
		ops[off]=aux.Stringid(99426088,0)  --"融合召唤"
		opval[off-1]=1
		off=off+1
	end
	if rsg:GetCount()>0 then
		ops[off]=aux.Stringid(99426088,1)  --"仪式召唤"
		opval[off-1]=2
		off=off+1
	end
	if off==1 then return end
	-- 让玩家在融合召唤与仪式召唤（若都可用）之间进行选择。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		local sg=fsg1:Clone()
		if fsg2 then sg:Merge(fsg2) end
		-- 提示玩家选择要特殊召唤的卡（融合怪兽或仪式怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		fmg1:RemoveCard(tc)
		-- 判断所选融合怪兽是否采用普通素材组而非连锁素材组，并确认玩家是否不使用连锁素材；若是，则按通常融合召唤处理。
		if fsg1:IsContains(tc) and (fsg2==nil or not fsg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 在普通融合召唤选择素材前，重新设置融合素材中来自卡组的卡最多1张的限制。
				aux.FCheckAdditional=c99426088.frcheck
				-- 设置通用素材中来自卡组的卡最多1张的限制。
				aux.GCheckAdditional=c99426088.gcheck
			end
			-- 让玩家为所选融合怪兽选择一组合法的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,fmg1,nil,chkf)
			-- 清除融合素材限制。
			aux.FCheckAdditional=nil
			-- 清除通用素材限制。
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地（作为融合召唤的素材）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓和融合怪兽特殊召唤不作为同一组时点处理。
			Duel.BreakEffect()
			-- 以融合召唤方式将所选「魔键」融合怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材提供的素材组，为所选融合怪兽选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,fmg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	else
		::rcancel::
		-- 提示玩家从仪式召唤候选中选择要特殊召唤的仪式怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=rsg:Select(tp,1,1,nil):GetFirst()
		-- 在仪式召唤处理前，设置仪式素材中来自卡组的卡最多1张的限制。
		aux.RCheckAdditional=c99426088.frcheck
		-- 设置仪式素材通用检查中来自卡组的卡最多1张的限制。
		aux.RGCheckAdditional=c99426088.gcheck
		local rmg=rmg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if rmg2 then rmg:Merge(rmg2) end
		if tc.mat_filter then
			rmg=rmg:Filter(tc.mat_filter,tc,tp)
		else
			rmg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的仪式素材怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式素材合理性检查：所选素材等级合计需达到仪式怪兽等级以上，且避免选择多余素材。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家从可用素材组中选择一组合法的仪式素材（等级合计大于等于仪式怪兽等级）。
		local mat=rmg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除仪式素材合理性检查。
		aux.GCheckAdditional=nil
		if not mat then
			-- 清除仪式素材数量限制（用于重新选择时）。
			aux.RCheckAdditional=nil
			-- 清除仪式素材通用限制。
			aux.RGCheckAdditional=nil
			goto rcancel
		end
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if dmat:GetCount()>0 then
			mat:Sub(dmat)
			-- 将作为仪式素材的卡组通常怪兽送去墓地。
			Duel.SendtoGrave(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 解放其余仪式素材怪兽（若为墓地仪式魔人等特殊素材则除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使仪式素材的解放/送墓与仪式怪兽特殊召唤不作为同一组时点处理。
		Duel.BreakEffect()
		-- 以仪式召唤方式将所选「魔键」仪式怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		-- 清除仪式素材数量限制（处理结束后）。
		aux.RCheckAdditional=nil
		-- 清除仪式素材通用限制（处理结束后）。
		aux.RGCheckAdditional=nil
	end
end
