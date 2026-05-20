--神炎竜ルベリオン
-- 效果：
-- 暗属性怪兽＋「阿不思的落胤」
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合，丢弃1张手卡才能发动。自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把除「神炎龙 赫界龙」外的1只8星以下的融合怪兽融合召唤。这个回合，这张卡不能攻击，自己不是融合怪兽不能从额外卡组特殊召唤。
function c70534340.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「阿不思的落胤」加1只暗属性怪兽
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,true,true)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡融合召唤的场合，丢弃1张手卡才能发动。自己的场上·墓地·除外状态的怪兽作为融合素材回到卡组，把除「神炎龙 赫界龙」外的1只8星以下的融合怪兽融合召唤。这个回合，这张卡不能攻击，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70534340,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,70534340)
	e1:SetCondition(c70534340.spcon)
	e1:SetCost(c70534340.spcost)
	e1:SetTarget(c70534340.sptg)
	e1:SetOperation(c70534340.spop)
	c:RegisterEffect(e1)
end
-- 烙印融合等卡片进行融合召唤时的素材合法性检查函数
function c70534340.branded_fusion_check(tp,sg,fc)
	-- 检查融合素材中是否包含「阿不思的落胤」和暗属性怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsFusionAttribute,ATTRIBUTE_DARK)
end
-- 效果发动条件：这张卡融合召唤成功的场合
function c70534340.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果发动代价：丢弃1张手卡
function c70534340.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤满足作为融合素材回到卡组条件的卡片（用于发动时的可行性检查）
function c70534340.filter0(c)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 过滤满足作为融合素材回到卡组条件且不受当前效果影响的卡片（用于效果处理时）
function c70534340.filter1(c,e)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中除「神炎龙 赫界龙」以外的8星以下融合怪兽
function c70534340.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(8) and not c:IsCode(70534340) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标确认与操作信息注册
function c70534340.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上、墓地、除外状态中可作为融合素材的怪兽组
		local mg=Duel.GetMatchingGroup(c70534340.filter0,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查额外卡组是否存在可以使用上述素材融合召唤的合法怪兽
		local res=Duel.IsExistingMatchingCard(c70534340.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否存在可融合召唤的合法怪兽
				res=Duel.IsExistingMatchingCard(c70534340.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置回到卡组的操作信息（将场上、墓地、除外的怪兽送回卡组）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理函数：将素材回到卡组并进行融合召唤，同时适用不能攻击和特殊召唤限制
function c70534340.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取自己场上、墓地（受王家之谷影响）、除外状态中可作为融合素材的怪兽组
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c70534340.filter1),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中可以使用上述素材融合召唤的合法怪兽组
	local sg1=Duel.GetMatchingGroup(c70534340.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的合法怪兽组
		sg2=Duel.GetMatchingGroup(c70534340.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用自身效果进行融合召唤（若不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 给对方玩家确认里侧表示的融合素材
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:IsExists(c70534340.fdfilter,1,nil) then
				local cg=mat:Filter(c70534340.fdfilter,nil)
				-- 提示并显示被选为融合素材的卡片
				Duel.HintSelection(cg)
			end
			-- 将融合素材怪兽送回持有者卡组并洗牌
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与回到卡组同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 自己不是融合怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c70534340.splimit)
	-- 注册不能从额外卡组特殊召唤融合怪兽以外怪兽的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制只能从额外卡组特殊召唤融合怪兽
function c70534340.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤场上表侧表示、墓地或除外状态的融合素材卡（用于显示选择动画）
function c70534340.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
