--ダブル・トリガー
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●包含「弹丸」怪兽的自己墓地的怪兽作为融合素材除外，把1只融合怪兽融合召唤。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含「弹丸」怪兽的自己墓地的怪兽除外，从手卡把1只仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 初始化卡片效果：创建一个效果e1，设置其描述、分类、类型、发动代码、属性、目标与操作函数，并注册到卡片上，使这张卡获得“①：可以从以下效果选择1个发动”的启动效果。
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
-- 融合素材候选筛选：选择自己墓地中满足“是怪兽、可以作为融合素材、可以被除外”的卡片作为融合素材候补。
function s.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 通用除外素材候选筛选：选择自己墓地中满足“是怪兽、可以被除外”的卡片，用于仪式召唤和连锁素材相关的除外素材。
function s.filter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 融合怪兽候选筛选：从额外卡组中选择是融合怪兽、满足额外条件（连锁素材等）、能够以融合召唤方式特殊召唤并且能和当前素材组完成融合的怪兽。
function s.fspfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材追加检查：确认选中的融合素材组中至少包含一只「弹丸」怪兽。
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x102)
end
-- 仪式素材追加检查：确认选中的仪式素材组中至少包含一只「弹丸」怪兽。
function s.rcheck(tp,g,c)
	return g:IsExists(Card.IsSetCard,1,nil,0x102)
end
-- 目标判定与发动选择：先分别判断融合召唤和仪式召唤是否可行，再让玩家选择要发动哪个分支；同时设置对应的使用次数限制和操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取自己墓地中满足融合素材条件的所有怪兽，作为融合召唤的候选素材组。
	local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,tp)
	-- 设置融合素材的追加检查函数，要求融合素材必须包含「弹丸」怪兽。
	aux.FCheckAdditional=s.fcheck
	-- 检查额外卡组中是否存在能够使用当前墓地素材进行融合召唤的融合怪兽。
	local b1=Duel.IsExistingMatchingCard(s.fspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		-- 在效果费用已确认时，检查本回合融合分支是否尚未使用（通过id对应的flag effect是否为0）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	if not b1 then
		-- 获取当前玩家适用的“连锁素材”效果，若存在则可能允许使用额外卡组作为融合素材。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 若存在连锁素材，用连锁素材提供的追加素材组再次检查额外卡组中是否存在可进行融合召唤的怪兽。
			b1=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
				-- 在效果费用已确认时，检查本回合融合分支是否尚未使用（与普通融合分支共用同一flag）。
				and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
		end
	end
	-- 清除融合素材追加检查，避免影响后续其他效果的处理。
	aux.FCheckAdditional=nil
	-- 设置仪式素材的追加检查函数，要求仪式素材必须包含「弹丸」怪兽。
	aux.RCheckAdditional=s.rcheck
	-- 获取自己墓地中可作为仪式素材（可除外）的怪兽组。
	local rg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil,tp)
	-- 检查手卡中是否存在能够通过仪式召唤特殊召唤、且用当前墓地素材组能满足等级合计要求的仪式怪兽。
	local b2=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,Group.CreateGroup(),rg,Card.GetLevel,"Greater")
		-- 在效果费用已确认时，检查本回合仪式分支是否尚未使用（通过id+o对应的flag effect是否为0）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	-- 清除仪式素材追加检查。
	aux.RCheckAdditional=nil
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 通过弹窗让玩家在“融合召唤”和“仪式召唤”两个分支中选择一个（只有可行的分支可选）。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"融合召唤"
			{b2,aux.Stringid(id,2),2})  --"仪式召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
			-- 选择融合分支时，给玩家注册一个结束阶段重置的flag效果，表示本回合融合分支已经使用过。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：本效果将从额外卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置操作信息：本效果将从墓地除外1只以上怪兽。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	end
	if op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
			-- 选择仪式分支时，给玩家注册一个结束阶段重置的flag效果，表示本回合仪式分支已经使用过。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：本效果将从手卡特殊召唤1只仪式怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		-- 设置操作信息：本效果将从墓地除外1只以上怪兽。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果处理：根据发动时选择的分支执行融合召唤或仪式召唤，包括选择素材、除外/解放素材、特殊召唤怪兽及完成后续处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local chkf=tp
		-- 获取自己墓地中满足融合素材条件且不受“王家长眠之谷”影响的怪兽组，用于实际执行融合召唤。
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,tp)
		-- 设置融合素材的追加检查函数，确保融合素材中包含「弹丸」怪兽。
		aux.FCheckAdditional=s.fcheck
		-- 获取额外卡组中所有能够使用当前墓地素材进行融合召唤的融合怪兽候选。
		local sg1=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取当前玩家适用的“连锁素材”效果，判断是否可用额外卡组怪兽作为融合素材。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 若存在连锁素材，用其提供的追加素材组获取额外卡组中可融合召唤的怪兽候选。
			sg2=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断所选融合怪兽是否属于普通墓地素材可完成的融合；如果不是连锁素材专用候选，或玩家选择不使用连锁素材，则执行普通融合召唤流程。
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 从素材组中选择符合该融合怪兽要求的融合素材。
				local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat)
				-- 将选中的融合素材表侧表示除外，作为融合召唤的素材消耗。
				Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断效果处理，使素材除外与后续特殊召唤分开处理，避免错过时点。
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤方式特殊召唤到场上。
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 若使用了连锁素材，则选择对应的素材并调用连锁素材的操作函数完成特殊召唤。
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
		-- 清除融合素材追加检查。
		aux.FCheckAdditional=nil
	elseif e:GetLabel()==2 then
		::rcancel::
		-- 获取自己墓地中可作为仪式素材且不受“王家长眠之谷”影响的怪兽组。
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter2),tp,LOCATION_GRAVE,0,nil,tp)
		-- 设置仪式素材的追加检查函数，确保仪式素材中包含「弹丸」怪兽。
		aux.RCheckAdditional=s.rcheck
		-- 提示玩家选择要仪式召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只能够满足仪式召唤条件（素材等级合计大于等于其等级）的仪式怪兽。
		local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,aux.TRUE,e,tp,Group.CreateGroup(),mg,Card.GetLevel,"Greater")
		local tc=tg:GetFirst()
		if tc then
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			end
			local lv=tc:GetLevel()
			-- 设置仪式召唤的额外素材合理性检查：要求素材等级合计大于等于仪式怪兽的等级。
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
			-- 提示玩家选择要除外的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 从墓地素材组中选择一组满足仪式召唤条件（包含「弹丸」怪兽且等级合计大于等于仪式怪兽等级）的素材。
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
			-- 清除仪式召唤额外素材合理性检查。
			aux.GCheckAdditional=nil
			if not mat then
				-- 清除仪式素材追加检查（用于选择失败跳转重选时）。
				aux.RCheckAdditional=nil
				goto rcancel
			end
			tc:SetMaterial(mat)
			-- 将选中的仪式素材解放/除外，完成仪式召唤的代价处理。
			Duel.ReleaseRitualMaterial(mat)
			-- 中断效果处理，使素材处理与仪式召唤分开处理，避免错过时点。
			Duel.BreakEffect()
			-- 将仪式怪兽以仪式召唤方式特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
		-- 清除仪式素材追加检查。
		aux.RCheckAdditional=nil
	end
end
