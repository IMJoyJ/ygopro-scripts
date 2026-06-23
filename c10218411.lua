--二重融合
-- 效果：
-- ①：支付500基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册这张卡的效果逻辑。
function s.initial_effect(c)
	-- 在自己回合的自由时点可以发动。支付500基本分，从额外卡组融合召唤1只融合怪兽。并且在此之后，可以再融合召唤1只融合怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.fusion_effect=true
-- 发动代价：支付500基本分。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否拥有至少500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分。
	Duel.PayLPCost(tp,500)
end
-- 过滤不受该卡效果影响的怪兽。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤符合融合召唤条件的额外卡组融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查自己手卡、场上的融合素材是否能进行融合召唤。
function s.fcon(e,tp)
	local chkf=tp
	-- 获取玩家可用的融合素材怪兽（过滤掉不受此卡效果影响的卡）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检查额外卡组中是否存在可用手上、场上素材融合召唤的怪兽。
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 检查是否有其他效果（如连锁素材）替代了融合素材获取方式。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用替代融合效果对应的素材检查额外卡组是否能融合召唤。
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	return res
end
-- 确认是否至少可以进行一次融合召唤，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.fcon(e,tp) end
	-- 设置特殊召唤（融合召唤）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行单次融合召唤处理的辅助函数，成功时返回1，失败时返回0。
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取常规融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取可以使用常规素材融合召唤的怪兽组合。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取替代融合材料的连锁效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取可以使用连锁效果提供素材进行融合召唤的怪兽组合。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示语：选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规素材方式进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择常规融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 切断效果连接，用于时点切分。
			Duel.BreakEffect()
			-- 将融合怪兽表侧表示特殊召唤（融合召唤）到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 使用连锁效果的可用材料组选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		return 1
	end
	return 0
end
-- 卡片发动时的主要执行逻辑（包含第一融合召唤，以及询问并执行第二次融合召唤的流程）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if s.fop(e,tp,eg,ep,ev,re,r,rp)>0 then
		-- 刷新场上的卡片状态（通常在连续处理之间调用）。
		Duel.Readjust()
		-- 确认是否还可以进行融合召唤，并询问玩家是否进行第二次融合召唤。
		if s.fcon(e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否继续融合召唤？"
			-- 切断第一次融合召唤与第二次融合召唤的效果连接，用于时点切分。
			Duel.BreakEffect()
			s.fop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
