--烙印融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
function c44362883.initial_effect(c)
	-- 记录该卡牌效果中涉及的「阿不思的落胤」卡名代码
	aux.AddCodeList(c,68468459)
	-- ①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44362883+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c44362883.cost)
	e1:SetTarget(c44362883.target)
	e1:SetOperation(c44362883.activate)
	c:RegisterEffect(e1)
	-- 设置一个用于记录特殊召唤次数的计数器，用于限制每回合只能发动一次
	Duel.AddCustomActivityCounter(44362883,ACTIVITY_SPSUMMON,c44362883.counterfilter)
end
-- 计数器过滤函数，排除从额外卡组特殊召唤且不是融合怪兽的怪兽
function c44362883.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 发动时检查是否为该回合第一次发动，若不是则不能发动
function c44362883.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家在该回合是否已经发动过特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(44362883,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44362883.splimit)
	-- 将效果注册给玩家，使该效果生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能从额外卡组特殊召唤非融合怪兽
function c44362883.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 过滤函数，筛选出可以作为融合素材的怪兽（类型为怪兽、可作为融合素材、可送入墓地）
function c44362883.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤函数，筛选出不受效果影响的怪兽
function c44362883.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，筛选出满足融合召唤条件的融合怪兽（必须包含「阿不思的落胤」为素材、可特殊召唤）
function c44362883.filter2(c,e,tp,m,f,chkf)
	-- 判断融合怪兽是否包含「阿不思的落胤」为素材
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置融合检查附加条件，用于限制融合素材数量和包含特定卡名
	aux.FCheckAdditional=c.branded_fusion_check or c44362883.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
	return res
end
-- 融合检查函数，限制融合素材数量不超过2张且必须包含「阿不思的落胤」
function c44362883.fcheck(tp,sg,fc)
	return sg:GetCount()<=2 and sg:IsExists(Card.IsFusionCode,1,nil,68468459)
end
-- ①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
function c44362883.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取玩家卡组中可作为融合素材的怪兽组
		local mg2=Duel.GetMatchingGroup(c44362883.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c44362883.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果中的过滤函数检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c44362883.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示将要特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
function c44362883.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组（手卡和场上的怪兽），并排除受效果影响的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44362883.filter1,nil,e)
	-- 获取玩家卡组中可作为融合素材的怪兽组
	local mg2=Duel.GetMatchingGroup(c44362883.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c44362883.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果中的过滤函数获取满足条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c44362883.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合召唤方式，否则使用连锁融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置融合检查附加条件，用于限制融合素材数量和包含特定卡名
			aux.FCheckAdditional=tc.branded_fusion_check or c44362883.fcheck
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除融合检查附加条件
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合召唤所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
