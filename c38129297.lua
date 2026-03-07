--ダブル・トリガー
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●包含「弹丸」怪兽的自己墓地的怪兽作为融合素材除外，把1只融合怪兽融合召唤。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含「弹丸」怪兽的自己墓地的怪兽除外，从手卡把1只仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 创建卡的效果，设置为发动时可选择的自由连锁效果
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_FUSION_SUMMON)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤墓地中的怪兽，用于融合召唤的素材
function s.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤墓地中的怪兽，用于仪式召唤的素材
function s.filter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 检查融合怪兽是否可以特殊召唤
function s.fspfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查融合素材是否包含「弹丸」卡组
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x102)
end
-- 检查仪式召唤的素材是否包含「弹丸」卡组
function s.rcheck(tp,g,c)
	return g:IsExists(Card.IsSetCard,1,nil,0x102)
end
-- 判断是否可以发动此卡的效果，提供融合召唤或仪式召唤选项
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取玩家墓地中所有符合filter1条件的怪兽
	local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,tp)
	-- 设置融合召唤时的额外检查函数
	aux.FCheckAdditional=s.fcheck
	-- 检查是否存在满足融合召唤条件的融合怪兽
	local b1=Duel.IsExistingMatchingCard(s.fspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		-- 确保此卡效果每回合只能发动一次
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	if not b1 then
		-- 获取当前连锁的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查是否存在满足融合召唤条件的额外怪兽
			b1=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
				-- 确保此卡效果每回合只能发动一次
				and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
		end
	end
	-- 清除融合召唤时的额外检查函数
	aux.FCheckAdditional=nil
	-- 设置仪式召唤时的额外检查函数
	aux.RCheckAdditional=s.rcheck
	-- 获取玩家墓地中所有符合filter2条件的怪兽
	local rg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil,tp)
	-- 检查是否存在满足仪式召唤条件的仪式怪兽
	local b2=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,Group.CreateGroup(),rg,Card.GetLevel,"Greater")
		-- 确保此卡效果每回合只能发动一次
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	-- 清除仪式召唤时的额外检查函数
	aux.RCheckAdditional=nil
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动融合召唤或仪式召唤
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"融合召唤"
			{b2,aux.Stringid(id,2),2})  --"仪式召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
			-- 注册融合召唤效果的使用标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置融合召唤时特殊召唤的卡牌信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置融合召唤时除外的卡牌信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	end
	if op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
			-- 注册仪式召唤效果的使用标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置仪式召唤时特殊召唤的卡牌信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		-- 设置仪式召唤时除外的卡牌信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 执行卡的效果发动，根据选择的选项进行融合召唤或仪式召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local chkf=tp
		-- 获取玩家墓地中所有符合filter1条件的怪兽（排除王家长眠之谷影响）
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,tp)
		-- 设置融合召唤时的额外检查函数
		aux.FCheckAdditional=s.fcheck
		-- 获取满足融合召唤条件的融合怪兽
		local sg1=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取当前连锁的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取满足融合召唤条件的额外融合怪兽
			sg2=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断选择的融合怪兽是否来自第一组融合怪兽
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 选择融合怪兽的融合素材
				local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat)
				-- 将融合素材除外
				Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将融合怪兽特殊召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 选择融合怪兽的额外融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
		-- 清除融合召唤时的额外检查函数
		aux.FCheckAdditional=nil
	elseif e:GetLabel()==2 then
		::rcancel::
		-- 获取玩家墓地中所有符合filter2条件的怪兽（排除王家长眠之谷影响）
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter2),tp,LOCATION_GRAVE,0,nil,tp)
		-- 设置仪式召唤时的额外检查函数
		aux.RCheckAdditional=s.rcheck
		-- 提示玩家选择要特殊召唤的仪式怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足仪式召唤条件的仪式怪兽
		local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,aux.TRUE,e,tp,Group.CreateGroup(),mg,Card.GetLevel,"Greater")
		local tc=tg:GetFirst()
		if tc then
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			end
			local lv=tc:GetLevel()
			-- 设置仪式召唤时的额外检查函数
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
			-- 提示玩家选择要除外的仪式召唤素材
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 选择满足仪式召唤条件的仪式素材
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
			-- 清除仪式召唤时的额外检查函数
			aux.GCheckAdditional=nil
			if not mat then
				-- 清除仪式召唤时的额外检查函数
				aux.RCheckAdditional=nil
				goto rcancel
			end
			tc:SetMaterial(mat)
			-- 将仪式召唤的素材除外
			Duel.ReleaseRitualMaterial(mat)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将仪式怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
		-- 清除仪式召唤时的额外检查函数
		aux.RCheckAdditional=nil
	end
end
