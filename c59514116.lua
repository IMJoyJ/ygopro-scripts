--黒魔術の秘儀
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●包含「黑魔术师」或「黑魔术少女」的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含「黑魔术师」或「黑魔术少女」的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
function c59514116.initial_effect(c)
	-- 注册卡片记有「黑魔术师」和「黑魔术少女」的代码列表
	aux.AddCodeList(c,46986414,38033121)
	-- ①：可以从以下效果选择1个发动。●包含「黑魔术师」或「黑魔术少女」的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含「黑魔术师」或「黑魔术少女」的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_FUSION_SUMMON)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c59514116.target)
	e1:SetOperation(c59514116.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤不受此卡效果影响的怪兽
function c59514116.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤额外卡组中可以进行融合召唤的融合怪兽
function c59514116.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材检查函数：检查融合素材中是否包含「黑魔术师」或「黑魔术少女」
function c59514116.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,46986414,38033121)
end
-- 仪式素材检查函数：检查仪式解放的怪兽中是否包含「黑魔术师」或「黑魔术少女」
function c59514116.rcheck(tp,g,c)
	return g:IsExists(Card.IsCode,1,nil,46986414,38033121)
end
-- 效果发动时的目标选择与可行性检查，并让玩家选择发动“融合召唤”或“仪式召唤”效果
function c59514116.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取玩家可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp)
	-- 设定融合素材的额外检查函数（必须包含「黑魔术师」或「黑魔术少女」）
	aux.FCheckAdditional=c59514116.fcheck
	-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的怪兽
	local res1=Duel.IsExistingMatchingCard(c59514116.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res1 then
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查在使用连锁素材效果的素材时，是否存在可融合召唤的怪兽
			res1=Duel.IsExistingMatchingCard(c59514116.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	-- 重置融合素材额外检查函数
	aux.FCheckAdditional=nil
	-- 获取玩家可用的仪式素材
	local mg3=Duel.GetRitualMaterial(tp)
	-- 设定仪式素材的额外检查函数（必须包含「黑魔术师」或「黑魔术少女」）
	aux.RCheckAdditional=c59514116.rcheck
	local res2=mg3:IsExists(Card.IsCode,1,nil,46986414,38033121)
		-- 检查手卡中是否存在可以使用当前仪式素材进行仪式召唤的仪式怪兽
		and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,mg3,nil,Card.GetLevel,"Greater")
	-- 重置仪式素材额外检查函数
	aux.RCheckAdditional=nil
	if chk==0 then return res1 or res2 end
	local s=0
	if res1 and not res2 then
		-- 仅能进行融合召唤时，强制选择“融合召唤”选项
		s=Duel.SelectOption(tp,aux.Stringid(59514116,0))  --"融合召唤"
	end
	if not res1 and res2 then
		-- 仅能进行仪式召唤时，强制选择“仪式召唤”选项
		s=Duel.SelectOption(tp,aux.Stringid(59514116,1))+1  --"仪式召唤"
	end
	if res1 and res2 then
		-- 融合召唤和仪式召唤均可行时，由玩家选择其中一个效果发动
		s=Duel.SelectOption(tp,aux.Stringid(59514116,0),aux.Stringid(59514116,1))  --"融合召唤/仪式召唤"
	end
	e:SetLabel(s)
	if s==0 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		end
		-- 设置连锁信息：从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
	if s==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置连锁信息：从手卡特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
-- 效果处理的核心逻辑，根据玩家的选择执行融合召唤或仪式召唤
function c59514116.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local chkf=tp
		-- 获取并过滤不受效果影响的可用融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(c59514116.filter1,nil,e)
		-- 设定融合素材的额外检查函数（必须包含「黑魔术师」或「黑魔术少女」）
		aux.FCheckAdditional=c59514116.fcheck
		-- 获取额外卡组中所有可以使用当前素材进行融合召唤的怪兽组
		local sg1=Duel.GetMatchingGroup(c59514116.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取在使用连锁素材效果的素材时，额外卡组中可融合召唤的怪兽组
			sg2=Duel.GetMatchingGroup(c59514116.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用常规融合素材进行融合召唤（若可以使用连锁素材，则询问玩家是否使用连锁素材效果）
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家选择融合召唤所需的融合素材
				local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat)
				-- 将选定的融合素材送去墓地
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果，使后续的特殊召唤不与送墓同时处理
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 让玩家从连锁素材效果提供的素材中选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
		-- 重置融合素材额外检查函数
		aux.FCheckAdditional=nil
	elseif e:GetLabel()==1 then
		::rcancel::
		-- 获取玩家可用的仪式素材
		local mg=Duel.GetRitualMaterial(tp)
		-- 设定仪式素材的额外检查函数（必须包含「黑魔术师」或「黑魔术少女」）
		aux.RCheckAdditional=c59514116.rcheck
		-- 提示玩家选择要特殊召唤的仪式怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡选择1只可以进行仪式召唤的仪式怪兽
		local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
		local tc=tg:GetFirst()
		if tc then
			mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			-- 设定仪式解放素材的等级合计检查函数（等级合计需在仪式怪兽等级以上）
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
			-- 提示玩家选择要解放的仪式素材
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			-- 让玩家选择满足等级和特定限制条件的仪式解放素材
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
			-- 重置仪式解放素材的等级合计检查函数
			aux.GCheckAdditional=nil
			if not mat then
				-- 重置仪式素材额外检查函数（在选择取消时）
				aux.RCheckAdditional=nil
				goto rcancel
			end
			tc:SetMaterial(mat)
			-- 解放选定的仪式素材
			Duel.ReleaseRitualMaterial(mat)
			-- 中断当前效果，使后续的特殊召唤不与解放同时处理
			Duel.BreakEffect()
			-- 将仪式怪兽以仪式召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
		-- 重置仪式素材额外检查函数
		aux.RCheckAdditional=nil
	end
end
