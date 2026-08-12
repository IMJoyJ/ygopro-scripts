--絵札融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把战士族·光属性的融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己场上有「王后骑士」「卫兵骑士」「国王骑士」的其中任意种存在的场合，自己卡组的怪兽也能有最多1只作为融合素材。
function c29062925.initial_effect(c)
	-- 记录该卡牌效果中涉及的其他卡片编号，用于后续效果判断
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：从自己的手卡·场上把战士族·光属性的融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己场上有「王后骑士」「卫兵骑士」「国王骑士」的其中任意种存在的场合，自己卡组的怪兽也能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29062925+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c29062925.target)
	e1:SetOperation(c29062925.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标怪兽是否为「王后骑士」「卫兵骑士」「国王骑士」中的一种且正面表示
function c29062925.exconfilter(c)
	return c:IsCode(25652259,64788463,90876561) and c:IsFaceup()
end
-- 判断自己场上是否存在「王后骑士」「卫兵骑士」「国王骑士」中任意一种的怪兽
function c29062925.excon(tp)
	-- 判断自己场上是否存在「王后骑士」「卫兵骑士」「国王骑士」中任意一种的怪兽
	return Duel.IsExistingMatchingCard(c29062925.exconfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断目标怪兽是否免疫当前效果
function c29062925.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断目标怪兽是否为光属性、战士族、融合怪兽且能特殊召唤
function c29062925.filter2(c,e,tp,m,f,chkf)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数：判断目标怪兽是否为怪兽、可作为融合素材、能送去墓地
function c29062925.fexfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 融合素材检查函数：确保融合素材中来自卡组的数量不超过1只
function c29062925.frcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 融合素材检查函数：确保融合素材中来自卡组的数量不超过1只
function c29062925.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 效果的发动条件判断函数，用于判断是否能发动此效果
function c29062925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组（包括手牌和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		if c29062925.excon(tp) then
			-- 获取玩家卡组中满足条件的怪兽组，用于作为额外融合素材
			local mg2=Duel.GetMatchingGroup(c29062925.fexfilter,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设置融合素材额外检查函数，限制卡组中融合素材数量
				aux.FCheckAdditional=c29062925.frcheck
				-- 设置融合素材额外检查函数，限制卡组中融合素材数量
				aux.GCheckAdditional=c29062925.gcheck
			end
		end
		-- 检查是否存在满足条件的融合怪兽可从额外卡组特殊召唤
		local res=Duel.IsExistingMatchingCard(c29062925.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除融合素材额外检查函数
		aux.FCheckAdditional=nil
		-- 清除融合素材额外检查函数
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前连锁中影响融合召唤的素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽可从额外卡组特殊召唤
				res=Duel.IsExistingMatchingCard(c29062925.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息，表示将特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果的发动处理函数，用于执行融合召唤操作
function c29062925.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组（包括手牌和场上的怪兽），并排除免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29062925.filter1,nil,e)
	local exmat=false
	if c29062925.excon(tp) then
		-- 获取玩家卡组中满足条件的怪兽组，用于作为额外融合素材
		local mg2=Duel.GetMatchingGroup(c29062925.fexfilter,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 设置融合素材额外检查函数，限制卡组中融合素材数量
		aux.FCheckAdditional=c29062925.frcheck
		-- 设置融合素材额外检查函数，限制卡组中融合素材数量
		aux.GCheckAdditional=c29062925.gcheck
	end
	-- 获取满足条件的融合怪兽组，用于特殊召唤
	local sg1=Duel.GetMatchingGroup(c29062925.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除融合素材额外检查函数
	aux.FCheckAdditional=nil
	-- 清除融合素材额外检查函数
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁中影响融合召唤的素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽组，用于特殊召唤
		sg2=Duel.GetMatchingGroup(c29062925.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材选择方式，否则使用连锁效果的融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置融合素材额外检查函数，限制卡组中融合素材数量
				aux.FCheckAdditional=c29062925.frcheck
				-- 设置融合素材额外检查函数，限制卡组中融合素材数量
				aux.GCheckAdditional=c29062925.gcheck
			end
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除融合素材额外检查函数
			aux.FCheckAdditional=nil
			-- 清除融合素材额外检查函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
