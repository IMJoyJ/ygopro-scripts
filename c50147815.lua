--三幻魔合殺
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只「三幻魔」怪兽守备表示特殊召唤。那之后，自己场上有原本等级是10星的「三幻魔」怪兽2只以上存在的场合，可以把对方场上1张表侧表示卡的效果无效并破坏。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「幻魔」融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册2个效果：手卡/墓地特殊召唤「三幻魔」怪兽并视场上卡片状况追加无效破坏对方卡片的效果（效果①），以及墓地除外用手卡/场上的怪兽为融合素材融合召唤「幻魔」融合怪兽的效果（效果②）。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「三幻魔」怪兽守备表示特殊召唤。那之后，自己场上有原本等级是10星的「三幻魔」怪兽2只以上存在的场合，可以把对方场上1张表侧表示卡的效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「幻魔」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 检查自身是否能够作为cost除外，并将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于判断手牌或墓地中的「三幻魔」怪兽是否能以守备表示特殊召唤。
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1144) or not c:IsType(TYPE_MONSTER) then return false end
	-- 判断该怪兽是否能被特殊召唤（包含特殊的召唤限制检测）。
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c),POS_FACEUP_DEFENSE)
end
-- 效果①的发动靶向检测函数：检查己方主要怪兽区域是否有空位，且手牌或墓地中是否存在可特殊召唤的「三幻魔」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在满足特殊召唤条件的「三幻魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手牌或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤函数：用于判断是否是场上表侧表示、原本等级为10星且是「三幻魔」的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()==10 and c:IsSetCard(0x1144)
end
-- 效果①的实际处理函数：特殊召唤手牌或墓地中的1只「三幻魔」怪兽；若召唤成功且场上有2只以上原本等级是10星的「三幻魔」怪兽存在，可选择对方场上1张表侧表示的卡的效果无效并破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若己方主要怪兽区域没有可用的空位，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或墓地选择1只满足条件且不受墓地针对效果影响的「三幻魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local res=0
		-- 判断特殊召唤形式的标志效果（特殊处理）。
		local flag=aux.PhantasmsSpSummonType(tc)
		-- 将选择的怪兽以守备表示特殊召唤。
		res=Duel.SpecialSummon(tc,0,tp,tp,false,flag,POS_FACEUP_DEFENSE)
		if res>0 then
			-- 检查己方场上是否存在2只以上原本等级是10星的「三幻魔」怪兽。
			if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,2,nil)
				-- 检查对方场上是否存在可以被无效的表侧表示卡片。
				and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
				-- 询问玩家是否追加效果无效并破坏的处理。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡无效？"
				-- 中断当前处理，使之前的特殊召唤与之后的无效破坏不视为同时处理。
				Duel.BreakEffect()
				-- 提示玩家选择要无效的卡片。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
				-- 让玩家选择对方场上1张表侧表示卡片。
				local ng=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
				-- 为选择的卡片显示被选为对象的动画效果。
				Duel.HintSelection(ng)
				local nc=ng:GetFirst()
				if nc:IsCanBeDisabledByEffect(e) then
					-- 在选择的目标卡上注册效果无效的效果。
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					nc:RegisterEffect(e1)
					-- 在选择的目标卡上注册使效果发动的效果无效的效果。
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					nc:RegisterEffect(e2)
					if tc:IsType(TYPE_TRAPMONSTER) then
						-- 若是陷阱怪兽，则另外注册使其陷阱怪兽效果无效的效果。
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
						e3:SetReset(RESET_EVENT+RESETS_STANDARD)
						nc:RegisterEffect(e3)
					end
					-- 刷新场上受到无效化影响卡片的无效状态。
					Duel.AdjustInstantly()
					-- 使和该被破坏卡片有关的连锁均无效化。
					Duel.NegateRelatedChain(nc,RESET_TURN_SET)
					-- 将无效效果后的对方卡片破坏。
					Duel.Destroy(nc,REASON_EFFECT)
				end
			end
			if flag then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤函数：用于筛选未受到当前效果免疫影响的融合素材。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：用于判断额外卡组中是否存在满足此时融合召唤条件的「幻魔」融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x144) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②的靶向检测函数：检索己方可用的融合素材和连锁融合效果，检查额外卡组是否存在此时可以融合召唤的「幻魔」融合怪兽，并设置融合召唤的操作信息。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方当前未免疫该效果的融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检测在常规融合素材支持下，是否可融合召唤特定融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检索是否存在由于连锁融合效果而可使用的素材或效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检测在连锁融合环境下，是否可进行融合召唤。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，预计从额外卡组进行1次融合召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的实际处理函数：获取玩家所有可用的融合素材与当前可以融合召唤的「幻魔」融合怪兽，让玩家选择1只进行融合召唤并送去墓地相关素材。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的常规融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检索额外卡组中可以通过常规素材融合召唤的「幻魔」融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家所具有的连锁融合素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取玩家所有可以通过连锁融合素材效果召唤的「幻魔」融合怪兽。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择融合特殊召唤的对象卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 融合召唤分支路径判断：若玩家决定使用常规素材融合召唤该怪兽，则执行常规融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于该融合怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选作融合素材的卡片作为融合材料送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前处理。
			Duel.BreakEffect()
			-- 将融合召唤的怪兽在己方场上特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家选择使用连锁效果对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
