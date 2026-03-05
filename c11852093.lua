--DDD聖賢王アルフレッド
-- 效果：
-- 「DD」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上·除外状态的怪兽作为融合素材回到卡组，把1只「DDD」融合怪兽融合召唤。
-- ②：这张卡被除外的场合，以最多有自己场上的「DDD」怪兽数量的自己的墓地·除外状态的「契约书」永续魔法·永续陷阱卡为对象才能发动。那些卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化效果，设置融合召唤条件并注册两个效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用2个满足「DD」怪兽条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xaf),2,true)
	c:EnableReviveLimit()
	-- 效果①：自己主要阶段才能发动。自己的手卡·场上·除外状态的怪兽作为融合素材回到卡组，把1只「DDD」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡被除外的场合，以最多有自己场上的「DDD」怪兽数量的自己的墓地·除外状态的「契约书」永续魔法·永续陷阱卡为对象才能发动。那些卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"表侧表示放置"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2)
end
-- 过滤满足融合召唤条件的怪兽作为融合素材
function s.spfilter1(c,e)
	return (c:IsLocation(LOCATION_MZONE) or c:IsFaceupEx() and c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤满足融合召唤条件的融合怪兽
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x10af) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动条件判断
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取满足融合召唤条件的怪兽组
		local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示将特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息，表示将融合素材送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_REMOVED)
end
-- 过滤满足确认卡片条件的卡片
function s.cfilter(c)
	return c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤满足提示卡片条件的卡片
function s.hfilter(c)
	return c:IsLocation(LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- 效果①的发动处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取满足融合召唤条件的怪兽组
	local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.cfilter,1,nil) then
				local cg=mat1:Filter(s.cfilter,nil)
				-- 确认对方可见的卡片
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.hfilter,1,nil) then
				local cg=mat1:Filter(s.hfilter,nil)
				-- 显示被选为对象的动画效果
				Duel.HintSelection(cg)
			end
			-- 将融合素材送回卡组
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 选择连锁融合的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤满足契约书效果的卡片
function s.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xae) and c:IsFaceupEx() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤满足场上的DD怪兽的卡片
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af)
end
-- 效果②的发动条件判断
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tffilter(chkc,tp) end
	-- 获取满足契约书效果的卡片数量
	local count1=Duel.GetTargetCount(s.tffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,tp)
	-- 获取场上的DD怪兽数量
	local count2=Duel.GetMatchingGroupCount(s.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 判断效果②是否可以发动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and count1>0 and count2>0 end
	-- 计算可放置的契约书数量
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),count1,count2)
	-- 提示选择要放置到场上的契约书
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择要放置到场上的契约书
	local g=Duel.SelectTarget(tp,s.tffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil,tp)
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if gg:GetCount()>0 then
		-- 设置操作信息，表示将墓地的契约书移除
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,gg:GetCount(),0,0)
	end
end
-- 效果②的发动处理
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的卡片组
	local g=Duel.GetTargetsRelateToChain()
	-- 获取场上可用的魔法陷阱区域数量
	local sct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local ct=math.min(g:GetCount(),sct)
	local pg=g
	if ct<=0 then
		pg=Group.CreateGroup()
	elseif g:GetCount()>ct then
		-- 提示选择要放置到场上的契约书
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		pg=g:Select(tp,ct,ct,nil)
		g:Sub(pg)
	else
		g=Group.CreateGroup()
	end
	-- 遍历要放置的契约书
	for tc in aux.Next(pg) do
		-- 将契约书移动到场上
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if sg:GetCount()>0 then
		-- 将被移除的契约书送入墓地
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
