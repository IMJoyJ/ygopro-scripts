--星辰竜ムルル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「星辰」融合怪兽融合召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把对方场上1只表侧表示怪兽的效果无效。
local s,id,o=GetID()
-- 注册该卡效果：①自己·对方主要阶段把手卡·场上的怪兽作为融合素材将「星辰」融合怪兽融合召唤，此回合自己只能特殊召唤融合怪兽；②作为融合素材送墓的场合，从卡组盖放1张「星辰」魔陷，之后可使对方场上1只表侧表示怪兽的效果无效。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「星辰」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fspcon)
	e1:SetTarget(s.fsptg)
	e1:SetOperation(s.fspop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放魔陷"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 主要阶段融合效果的发动条件判定（自己或对方的主要阶段）
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 融合素材卡片的过滤条件（不能是不受效果影响的卡）
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽卡片的过滤条件（必须是「星辰」融合怪兽，能被效果特殊召唤，且能以给定的素材进行融合召唤）
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1c9) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 主要阶段融合效果的发动准备（判定是否存在可融合召唤的对象并设置操作信息）
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local chkf=tp
		-- 获取并过滤可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查是否有符合条件的融合怪兽可特殊召唤
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否受其他连锁素材效果（如链素材）的影响
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查受其他连锁素材效果影响下是否有符合条件的融合怪兽可特殊召唤
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤融合怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 主要阶段融合效果的效果处理（融合召唤「星辰」融合怪兽并施加只能特殊召唤融合怪兽的限制）
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理：获取并过滤可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 效果处理：获取符合融合召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理：获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果处理：获取使用连锁素材时符合融合召唤条件的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用常规融合素材或需要询问使用连锁素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，以便后续融合召唤
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材允许的范围内选择素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册“不能从额外卡组特殊召唤融合怪兽以外的怪兽”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 只能从额外卡组特殊召唤融合怪兽的限制过滤
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 盖放魔陷与无效效果的发动条件判定（这张卡作为融合素材送去墓地的场合）
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 可盖放的「星辰」魔法·陷阱卡的过滤条件
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放魔陷与无效效果的发动准备（检查是否有符合盖放条件的卡）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合盖放条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放魔陷与无效效果的效果处理（盖放「星辰」魔法·陷阱卡，然后可以使对方场上一只怪兽的效果无效）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张符合条件的「星辰」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡在自己场上盖放，并判断是否盖放成功
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 获取对方场上可被无效的表侧表示怪兽
		local sg=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
		-- 对方场上有怪兽时，询问玩家是否要把那只怪兽的效果无效
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽无效？"
			-- 提示玩家选择要无效效果的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 显示所选择的无效目标对象
			Duel.HintSelection(dg)
			-- 中断当前效果，以便后续进行无效处理
			Duel.BreakEffect()
			local nc=dg:GetFirst()
			if nc:IsCanBeDisabledByEffect(e) then
				-- 使被选择怪兽的相关连锁效果失效
				Duel.NegateRelatedChain(nc,RESET_TURN_SET)
				-- 那之后，可以把对方场上1只表侧表示怪兽的效果无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e1)
				-- 那之后，可以把对方场上1只表侧表示怪兽的效果无效。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e2)
			end
		end
	end
end
