--二重融合
-- 效果：
-- ①：支付500基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 定义卡片初始化函数，用于注册卡片效果
function s.initial_effect(c)
	-- ①：支付500基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.fusion_effect=true
-- 定义效果代价函数，处理支付500基本分的逻辑
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以支付500基本分作为发动代价
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- 定义素材过滤函数，筛选出不受当前效果影响的卡片
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽过滤函数，检查是否为可用素材融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义融合条件检查函数，验证是否可以进行融合召唤
function s.fcon(e,tp)
	local chkf=tp
	-- 获取玩家手卡·场上可用的融合素材组，并过滤掉受效果影响的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检查额外卡组是否存在至少1只可用当前素材进行融合召唤的融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取玩家当前受到的连锁素材效果（如《连锁素材》等卡的效果）
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材替代素材，检查额外卡组是否存在可融合召唤的怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	return res
end
-- 定义效果目标函数，设置效果处理的相关信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.fcon(e,tp) end
	-- 设置操作信息，声明此效果将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义融合召唤操作函数，执行实际的融合召唤处理
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡·场上可用的融合素材组并过滤
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可用通常素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中可用连锁素材进行融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送提示，要求选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的怪兽是否使用通常素材融合，或是否不使用连锁素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从素材组中选择融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地，标记为融合召唤使用
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓和特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到玩家场上表侧表示
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 使用连锁素材时，让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		return 1
	end
	return 0
end
-- 定义效果发动函数，处理完整的融合召唤流程及第二次融合
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if s.fop(e,tp,eg,ep,ev,re,r,rp)>0 then
		-- 刷新场上卡片信息，确保第一次融合召唤后的状态更新
		Duel.Readjust()
		-- 检查是否可以进行第二次融合召唤，并询问玩家是否发动
		if s.fcon(e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 中断效果处理，使第一次和第二次融合召唤视为不同时处理
			Duel.BreakEffect()
			s.fop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
