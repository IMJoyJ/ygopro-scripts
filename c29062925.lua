--絵札融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把战士族·光属性的融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己场上有「王后骑士」「卫兵骑士」「国王骑士」的其中任意种存在的场合，自己卡组的怪兽也能有最多1只作为融合素材。
function c29062925.initial_effect(c)
	-- 注册此卡效果文本中记载的王后骑士、卫兵骑士、国王骑士的卡名，使这些卡名与当前卡建立关联。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把战士族·光属性的融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己场上有「王后骑士」「卫兵骑士」「国王骑士」的其中任意种存在的场合，自己卡组的怪兽也能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29062925+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c29062925.target)
	e1:SetOperation(c29062925.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断一张卡是否为表侧表示的王后骑士、卫兵骑士或国王骑士。
function c29062925.exconfilter(c)
	return c:IsCode(25652259,64788463,90876561) and c:IsFaceup()
end
-- 定义额外素材可用条件：己方场上有至少1张表侧表示的王后骑士、卫兵骑士或国王骑士时返回真。
function c29062925.excon(tp)
	-- 实际检索己方主要怪兽区是否存在满足上述条件的骑士，存在则返回真。
	return Duel.IsExistingMatchingCard(c29062925.exconfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义素材过滤函数：排除免疫当前效果的怪兽，确保选为素材的卡可被该效果处理。
function c29062925.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽选择条件：光属性、战士族、融合怪兽，能够以融合召唤方式特殊召唤，且可用当前素材组构成融合素材；如果存在额外限制函数f则也需通过。
function c29062925.filter2(c,e,tp,m,f,chkf)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义卡组素材候选过滤：卡组中可作为融合素材且能被送去墓地的怪兽。
function c29062925.fexfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 附加检查：选定的融合素材中来自卡组的卡不能超过1张。
function c29062925.frcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 素材组检查：融合素材整体中来自卡组的卡不能超过1张。
function c29062925.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 效果发动时的目标处理：构建可用融合素材池（手卡·场上，以及满足条件时加入卡组素材），设置卡组素材数量限制；检查额外卡组是否存在可融合召唤的怪兽，若不存在则检查是否有连锁素材效果可提供替代素材；合法则登记特殊召唤操作。
function c29062925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家完整的融合素材组（包括手卡·场上怪兽及额外融合素材效果提供的素材）。
		local mg1=Duel.GetFusionMaterial(tp)
		if c29062925.excon(tp) then
			-- 获取卡组中可作为额外融合素材的怪兽组（用于后续合并到可用素材池）。
			local mg2=Duel.GetMatchingGroup(c29062925.fexfilter,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设置全局附加检查frcheck，限制所选融合素材中来自卡组的卡不超过1张。
				aux.FCheckAdditional=c29062925.frcheck
				-- 设置全局素材组检查gcheck，同样限制融合素材组中的卡组素材不超过1张。
				aux.GCheckAdditional=c29062925.gcheck
			end
		end
		-- 在普通素材池下检查额外卡组是否存在至少1只满足条件的融合怪兽，以决定效果能否发动。
		local res=Duel.IsExistingMatchingCard(c29062925.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除前面设置的附加检查frcheck，避免影响其他效果。
		aux.FCheckAdditional=nil
		-- 清除前面设置的素材组检查gcheck。
		aux.GCheckAdditional=nil
		if not res then
			-- 获取连锁素材效果（替代融合素材）的实例，若存在则可为融合召唤提供额外素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材提供的素材池mg2及附加条件mf下重新检查额外卡组是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c29062925.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次效果将进行的特殊召唤（融合召唤）信息，供连锁判定使用（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段：实际执行融合召唤。获取可用素材（排除免疫效果），满足骑士条件时加入卡组素材；选择要融合召唤的怪兽；若该怪兽也可用连锁素材召唤，则询问玩家是否使用连锁素材；根据选择用普通素材或连锁素材选择融合素材，送墓并特殊召唤，最后完成融合召唤手续。
function c29062925.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取普通融合素材池，并移除免疫当前效果的卡，得到实际可用的素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29062925.filter1,nil,e)
	local exmat=false
	if c29062925.excon(tp) then
		-- 获取卡组中可作为额外融合素材的怪兽组。
		local mg2=Duel.GetMatchingGroup(c29062925.fexfilter,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 设置附加检查frcheck，准备选择素材时限制卡组素材数量。
		aux.FCheckAdditional=c29062925.frcheck
		-- 设置素材组检查gcheck，限制卡组素材数量。
		aux.GCheckAdditional=c29062925.gcheck
	end
	-- 在普通素材池下筛选所有符合条件的融合怪兽，作为可选特殊召唤对象。
	local sg1=Duel.GetMatchingGroup(c29062925.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除附加检查frcheck。
	aux.FCheckAdditional=nil
	-- 清除素材组检查gcheck。
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果实例。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 在连锁素材池下筛选符合条件的融合怪兽，作为备选特殊召唤对象。
		sg2=Duel.GetMatchingGroup(c29062925.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽（显示选择消息）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否走普通素材流程：所选怪兽在普通素材可召唤列表内，且不使用连锁素材（或不存在连锁素材可选），则进入普通融合召唤分支。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置附加检查frcheck，为选择融合素材做准备。
				aux.FCheckAdditional=c29062925.frcheck
				-- 设置素材组检查gcheck，为选择融合素材做准备。
				aux.GCheckAdditional=c29062925.gcheck
			end
			-- 让玩家从普通素材池中选择该融合怪兽所需的融合素材（受卡组素材最多1张的限制）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除附加检查frcheck。
			aux.FCheckAdditional=nil
			-- 清除素材组检查gcheck。
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选定的融合素材以效果·融合素材原因送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续特殊召唤单独构成时点，防止错过融合召唤成功的诱发时机。
			Duel.BreakEffect()
			-- 以融合召唤方式将融合怪兽特殊召唤到己方场上，正面表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材池中选择融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
