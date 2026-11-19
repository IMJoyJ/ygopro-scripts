--三幻魔合殺
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只「三幻魔」怪兽守备表示特殊召唤。那之后，自己场上有原本等级是10星的「三幻魔」怪兽2只以上存在的场合，可以把对方场上1张表侧表示卡的效果无效并破坏。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「幻魔」融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果，为这张卡注册手卡·墓地特招「三幻魔」并附加无效破坏效果的发动效果(e1)，以及墓地除外融合召唤「幻魔」融合怪兽的效果(e2)
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己的手卡·墓地把1只「三幻魔」怪兽守备表示特殊召唤。那之后，自己场上有原本等级是10星的「三幻魔」怪兽2只以上存在的场合，可以把对方场上1张表侧表示卡的效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「幻魔」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为将墓地中的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
-- 过滤函数，筛选「三幻魔」怪兽且能以表侧守备表示按aux.PhantasmsSpSummonType指定的特殊召唤规则特殊召唤的怪兽
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1144) or not c:IsType(TYPE_MONSTER) then return false end
	-- 检查怪兽c是否可以被玩家tp以表侧守备表示特殊召唤（根据aux.PhantasmsSpSummonType决定是否无视苏生限制）
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c),POS_FACEUP_DEFENSE)
end
-- ①效果的Target函数，检查怪兽区空格及手卡·墓地存在可特招的「三幻魔」怪兽，并设置特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·墓地是否存在至少1只满足spfilter条件可特殊召唤的「三幻魔」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，声明将从自己的手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤函数，筛选场上表侧表示、原本等级为10星的「三幻魔」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()==10 and c:IsSetCard(0x1144)
end
-- ①效果的Operation函数，从手卡·墓地守备表示特招1只「三幻魔」怪兽；若满足10星三幻魔条件，则可选将对方场上1张表侧表示卡的效果无效并破坏
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在手卡·墓地选择1只满足spfilter且不受「王家长眠之谷」影响的「三幻魔」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local res=0
		-- 获取该「三幻魔」怪兽的特殊召唤标志位（用于判断是否无视苏生限制及后续完成正规召唤程序）
		local flag=aux.PhantasmsSpSummonType(tc)
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上，并记录特殊召唤成功的数量
		res=Duel.SpecialSummon(tc,0,tp,tp,false,flag,POS_FACEUP_DEFENSE)
		if res>0 then
			-- 检查自己怪兽区域是否存在至少2只原本等级为10星的「三幻魔」怪兽
			if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,2,nil)
				-- 检查对方场上是否存在至少1张可被无效效果的表侧表示卡
				and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
				-- 询问自己是否适用追加的无效并破坏效果（“是否把卡无效？”）
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡无效？"
				-- 插入效果处理中断，使之后无效并破坏对方卡的处理视为不同时处理
				Duel.BreakEffect()
				-- 向自己发送选择提示信息：“请选择要无效的卡”
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
				-- 让自己在对方场上选择1张可被无效的表侧表示卡
				local ng=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
				-- 向双方提示被选中的对方卡片ng
				Duel.HintSelection(ng)
				local nc=ng:GetFirst()
				if nc:IsCanBeDisabledByEffect(e) then
					-- 可以把对方场上1张表侧表示卡的效果无效
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					nc:RegisterEffect(e1)
					-- 可以把对方场上1张表侧表示卡的效果无效
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					nc:RegisterEffect(e2)
					if nc:IsType(TYPE_TRAPMONSTER) then
						-- 可以把对方场上1张表侧表示卡的效果无效
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
						e3:SetReset(RESET_EVENT+RESETS_STANDARD)
						nc:RegisterEffect(e3)
					end
					-- 立即刷新场上卡片的无效状态
					Duel.AdjustInstantly()
					-- 使与卡片nc相关的连锁效果发动处理无效化
					Duel.NegateRelatedChain(nc,RESET_TURN_SET)
					-- 以效果破坏那张对方表侧表示的卡nc
					Duel.Destroy(nc,REASON_EFFECT)
				end
			end
			if flag then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 融合素材过滤函数，筛选不受当前效果免疫的卡
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤函数，筛选额外卡组中满足融合素材要求且可融合召唤的「幻魔」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x144) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的Target函数，检测是否存在可用手卡·场上素材正规融合召唤的「幻魔」融合怪兽（含连锁素材），并设置特殊召唤操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡·场上可用作融合素材且不受此效果免疫的怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在可用mg1作为素材融合召唤的「幻魔」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查玩家tp是否受到连锁素材类替代融合素材效果的影响
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否能使用连锁素材的替代素材组mg2来融合召唤「幻魔」融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，声明将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的Operation函数，选择「幻魔」融合怪兽及融合素材并将其送去墓地后完成融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 重新获取自己手卡·场上不受此效果免疫的可用融合素材怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可用常规融合素材mg1融合召唤的「幻魔」融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家tp当前的连锁素材效果（若有）
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中可用连锁素材mg2融合召唤的「幻魔」融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否采用常规融合素材进行融合召唤（而非使用连锁素材）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让自己从mg1中选择融合召唤怪兽tc所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以融合素材效果的原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 插入效果处理中断，使送墓素材与后续融合召唤不同时处理
			Duel.BreakEffect()
			-- 以融合召唤方式将融合怪兽tc表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在适用连锁素材时，从替代素材组mg2中选择融合召唤tc所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
