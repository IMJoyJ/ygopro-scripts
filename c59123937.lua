--DDヴァイス・テュポーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时，把自己场上1只「DD」怪兽解放才能发动。从卡组把1只7星「DDD」怪兽特殊召唤。
-- ②：这张卡被送去墓地的回合的自己主要阶段才能发动。8星以上的「DDD」融合怪兽卡决定的包含这张卡的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
function c59123937.initial_effect(c)
	-- ①：这张卡召唤成功时，把自己场上1只「DD」怪兽解放才能发动。从卡组把1只7星「DDD」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59123937,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,59123937)
	e1:SetCost(c59123937.spcost)
	e1:SetTarget(c59123937.sptg)
	e1:SetOperation(c59123937.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c59123937.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合的自己主要阶段才能发动。8星以上的「DDD」融合怪兽卡决定的包含这张卡的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59123937,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,59123938)
	e1:SetCondition(c59123937.condition)
	e1:SetTarget(c59123937.target)
	e1:SetOperation(c59123937.operation)
	c:RegisterEffect(e1)
end
-- ①号效果的COST：解放自己场上1只「DD」怪兽
function c59123937.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「DD」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xaf) end
	-- 选择自己场上1只「DD」怪兽解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xaf)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤卡组中7星「DDD」怪兽的条件
function c59123937.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsSetCard(0x10af) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与检查
function c59123937.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（考虑解放自身腾出位置的情况）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在满足条件的7星「DDD」怪兽
		and Duel.IsExistingMatchingCard(c59123937.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特召1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理：从卡组特殊召唤1只7星「DDD」怪兽
function c59123937.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的7星「DDD」怪兽
	local g=Duel.SelectMatchingCard(tp,c59123937.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 在送去墓地的回合给自身注册标记，用于记录该卡已被送去墓地
function c59123937.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(59123937,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤墓地中可以作为融合素材且能被除外的怪兽
function c59123937.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤墓地中可以作为融合素材、能被除外且不受效果影响的怪兽
function c59123937.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中满足融合召唤条件的8星以上「DDD」融合怪兽
function c59123937.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x10af)
		and c:IsLevelAbove(8) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
		-- 检查额外卡组怪兽特殊召唤所需的可用怪兽区域空格数
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②号效果的发动条件：检查本回合这张卡是否被送去墓地（是否存在标记）
function c59123937.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(59123937)~=0
end
-- ②号效果的发动准备与检查
function c59123937.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己墓地中可作为融合素材的怪兽组
		local mg1=Duel.GetMatchingGroup(c59123937.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在可以使用墓地素材（包含自身）进行融合召唤的8星以上「DDD」融合怪兽
		local res=Duel.IsExistingMatchingCard(c59123937.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果的素材组再次检查是否可以进行融合召唤
				res=Duel.IsExistingMatchingCard(c59123937.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特召1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息（将墓地的这张卡除外）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,LOCATION_GRAVE)
end
-- ②号效果的处理：将墓地的素材除外，融合召唤1只8星以上「DDD」融合怪兽
function c59123937.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取自己墓地中可作为融合素材且不受效果影响的怪兽组
	local mg1=Duel.GetMatchingGroup(c59123937.filter1,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中可以使用墓地素材（包含自身）进行融合召唤的8星以上「DDD」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c59123937.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材效果时可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c59123937.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用自身效果进行融合召唤（若不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择包含自身在内的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤与除外不同时处理
			Duel.BreakEffect()
			-- 将选中的融合怪兽进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
