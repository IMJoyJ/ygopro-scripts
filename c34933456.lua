--聖なる法典
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把融合怪兽卡决定的包含魔法师族怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。「大贤者」融合怪兽融合召唤的场合，给「大贤者」怪兽装备的自己的魔法与陷阱区域的当作装备卡使用的融合素材怪兽也能作为融合素材使用。
function c34933456.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把融合怪兽卡决定的包含魔法师族怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。「大贤者」融合怪兽融合召唤的场合，给「大贤者」怪兽装备的自己的魔法与陷阱区域的当作装备卡使用的融合素材怪兽也能作为融合素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34933456+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c34933456.target)
	e1:SetOperation(c34933456.activate)
	c:RegisterEffect(e1)
end
-- 额外融合素材的候选筛选：位于自己魔陷区且当作装备卡使用的怪兽，若其装备对象是「大贤者」怪兽，且其原本种类包含怪兽，则可作为本次融合召唤的追加素材。
function c34933456.mttg(e,c)
	local tc=c:GetEquipTarget()
	return tc and tc:IsSetCard(0x150) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 额外融合素材效果的Value判定：仅当传入的卡c拥有「大贤者」字段时返回true；c为空时返回false。
function c34933456.mtval(e,c)
	if not c then return false end
	return c:IsSetCard(0x150)
end
-- 融合怪兽候选筛选：满足以下条件才可选为融合召唤对象：是融合怪兽、未被素材来源的追加条件f排除、能够以融合召唤方式特殊召唤，并且能用素材组m凑齐其融合素材。
function c34933456.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 将免疫本效果的卡从融合素材候选组中排除，避免无法被「神圣法典」效果处理。
function c34933456.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 追加的融合素材合法性检查：选定的融合素材群中必须至少存在1只魔法师族怪兽。
function c34933456.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,nil,1,RACE_SPELLCASTER)
end
-- 发动判定：临时给魔陷区中装备给「大贤者」怪兽的装备卡追加“可作为融合素材”的效果，然后检查额外卡组是否存在能用当前素材（含通常素材或连锁素材）凑齐含魔法师族素材并可融合召唤的融合怪兽；若存在则允许发动，并把后续操作标记为从额外卡组特殊召唤。
function c34933456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 「大贤者」融合怪兽融合召唤的场合，给「大贤者」怪兽装备的自己的魔法与陷阱区域的当作装备卡使用的融合素材怪兽也能作为融合素材使用。
		local me=Effect.CreateEffect(e:GetHandler())
		me:SetType(EFFECT_TYPE_FIELD)
		me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		me:SetTargetRange(LOCATION_SZONE,0)
		me:SetTarget(c34933456.mttg)
		me:SetValue(c34933456.mtval)
		-- 将该临时额外融合素材效果注册给tp方，使符合条件的魔陷区装备怪兽被纳入融合素材候选。
		Duel.RegisterEffect(me,tp)
		local chkf=tp
		-- 获取tp当前可用的全部融合素材组，包括手卡·场上的怪兽以及额外融合素材效果追加的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置全局融合素材追加检查函数，强制后续融合素材选择必须包含至少1只魔法师族怪兽。
		aux.FCheckAdditional=c34933456.fcheck
		-- 检查额外卡组是否存在至少1只融合怪兽，能够用正常素材组mg1凑齐包含魔法师族的融合素材并可作为融合召唤特殊召唤。
		local res=Duel.IsExistingMatchingCard(c34933456.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取tp当前适用的连锁素材/替代融合素材效果（若有），以便扩展素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材提供的素材组mg3及追加条件mf下，再次检查额外卡组是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c34933456.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除刚设置的全局融合素材追加检查函数，避免影响其他效果。
		aux.FCheckAdditional=nil
		me:Reset()
		return res
	end
	-- 设置本次效果的操作信息：将从额外卡组特殊召唤1只怪兽（用于融合召唤相关判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：重新启用魔陷区装备怪兽作为额外融合素材，过滤免疫本效果的卡，分别得到用正常素材和连锁素材可融合召唤的融合怪兽候选；选择1只后，若使用正常素材则选择素材→送墓→特殊召唤，若使用连锁素材则交给连锁素材效果处理，最后完成融合召唤程序并清理临时效果。
function c34933456.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己的手卡·场上把融合怪兽卡决定的包含魔法师族怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。「大贤者」融合怪兽融合召唤的场合，给「大贤者」怪兽装备的自己的魔法与陷阱区域的当作装备卡使用的融合素材怪兽也能作为融合素材使用。
	local me=Effect.CreateEffect(e:GetHandler())
	me:SetType(EFFECT_TYPE_FIELD)
	me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	me:SetTargetRange(LOCATION_SZONE,0)
	me:SetTarget(c34933456.mttg)
	me:SetValue(c34933456.mtval)
	-- 将额外融合素材效果重新注册到tp方，使魔陷区中符合条件的装备怪兽在效果处理时也能作为融合素材使用。
	Duel.RegisterEffect(me,tp)
	local chkf=tp
	-- 获取当前可用的全部融合素材，并去除不受本效果影响的卡，得到正常融合素材组mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c34933456.filter2,nil,e)
	-- 设置全局追加检查函数：本次融合素材组中必须包含至少1只魔法师族怪兽。
	aux.FCheckAdditional=c34933456.fcheck
	-- 用正常素材组mg1和发动时设置的参数，筛选出额外卡组中所有可作融合召唤的融合怪兽候选sg1。
	local sg1=Duel.GetMatchingGroup(c34933456.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取tp适用的连锁素材/替代融合素材效果（若存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材提供的素材组mg3和追加条件mf，筛选出额外卡组中可融合召唤的候选sg2。
		sg2=Duel.GetMatchingGroup(c34933456.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择提示，让tp在候选融合怪兽中选择1只要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断走通常融合还是连锁素材融合：若该怪兽可由通常素材召唤，且玩家不使用连锁素材（或该怪兽不在连锁素材候选中），则按通常素材处理；否则使用连锁素材效果。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让tp从正常素材组mg1中为融合怪兽tc选择一组融合素材，且该组素材必须包含魔法师族怪兽。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将所选融合素材以效果·素材·融合的理由送去墓地，完成融合素材的消费。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后特殊召唤的时点与送墓/选素材分开，避免时点被占有。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到tp场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材时，让tp从mg3中为融合怪兽tc选择一组融合素材（同样需满足包含魔法师族怪兽）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除全局追加素材检查函数，恢复默认的融合素材判定规则。
	aux.FCheckAdditional=nil
	me:Reset()
end
