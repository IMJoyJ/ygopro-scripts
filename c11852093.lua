--DDD聖賢王アルフレッド
-- 效果：
-- 「DD」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上·除外状态的怪兽作为融合素材回到卡组，把1只「DDD」融合怪兽融合召唤。
-- ②：这张卡被除外的场合，以最多有自己场上的「DDD」怪兽数量的自己的墓地·除外状态的「契约书」永续魔法·永续陷阱卡为对象才能发动。那些卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 卡片的初始化入口：注册融合素材条件（「DD」怪兽×2）和①融合召唤起动效果、②被除外时放置「契约书」的效果。
function s.initial_effect(c)
	-- 为该卡添加融合召唤手续：素材为2只「DD」系列怪兽，使该卡可作为融合怪兽被融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xaf),2,true)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。自己的手卡·场上·除外状态的怪兽作为融合素材回到卡组，把1只「DDD」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以最多有自己场上的「DDD」怪兽数量的自己的墓地·除外状态的「契约书」永续魔法·永续陷阱卡为对象才能发动。那些卡在自己场上表侧表示放置。
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
-- 定义融合素材的筛选条件：可作为融合素材、能回到卡组、且不受本效果影响的怪兽（手牌/场上表侧/除外表侧）。
function s.spfilter1(c,e)
	return (c:IsLocation(LOCATION_MZONE) or c:IsFaceupEx() and c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 定义融合召唤目标的筛选条件：额外卡组的「DDD」融合怪兽，能以当前素材组为素材进行融合召唤。
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x10af) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动条件判定：检查是否存在可融合召唤的「DDD」融合怪兽及可用素材（含连锁素材），并登记特殊召唤和回卡组的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手牌、场上、除外区中可作为融合素材的怪兽集合。
		local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
		-- 检查额外卡组是否存在至少1只能用该素材组融合召唤的「DDD」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家可用的连锁素材效果（替代融合素材），用于扩展融合素材选择。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材存在时，用其提供的替代素材组和融合手续再次检查能否融合召唤。
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记效果处理时将进行特殊召唤（从额外卡组取出1只融合怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记效果处理时融合素材回到卡组（来源为场上、手牌、除外）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_REMOVED)
end
-- 判断素材中是否存在里侧表示或手牌中的卡，这些卡需要向对方确认。
function s.cfilter(c)
	return c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 判断素材中是否存在除外区或场上表侧表示的卡，这些卡需要播放选中动画。
function s.hfilter(c)
	return c:IsLocation(LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- ①效果的融合召唤处理：选择融合怪兽与素材，素材回卡组后融合召唤；若使用连锁素材则调用其操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时重新获取当前可作为融合素材的怪兽集合（因处理时状态可能变化）。
	local mg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	-- 获取所有能用常规素材mg1融合召唤的「DDD」融合怪兽作为候选。
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理时获取连锁素材效果，用于处理替代融合。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组和手续，获取可融合召唤的「DDD」融合怪兽候选。
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否走常规素材融合；当需要连锁素材时询问玩家是否使用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家从常规素材组中选择融合召唤该怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.cfilter,1,nil) then
				local cg=mat1:Filter(s.cfilter,nil)
				-- 将素材中里侧表示或手牌的卡展示给对方确认。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.hfilter,1,nil) then
				local cg=mat1:Filter(s.hfilter,nil)
				-- 为素材中表侧表示或除外区的卡播放选中动画。
				Duel.HintSelection(cg)
			end
			-- 将融合素材送回持有者卡组并洗牌，原因为效果、素材和融合。
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，使素材回卡组和后续融合召唤不在同一时点，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧表示融合召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁素材路线下，玩家从替代素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的对象过滤：选择自己墓地/除外区的「契约书」永续魔法·永续陷阱，且不是禁止卡、场上不存在同名/限制冲突的卡。
function s.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xae) and c:IsFaceupEx() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 用于统计自己场上表侧表示的「DDD」怪兽数量（决定最多放置张数）。
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af)
end
-- ②效果的发动条件和目标选择：计算可放置的「契约书」数量上限，让玩家选择对应张数的对象，并登记离开墓地的信息。
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tffilter(chkc,tp) end
	-- 统计自己墓地/除外区中可作为对象的「契约书」卡数量。
	local count1=Duel.GetTargetCount(s.tffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,tp)
	-- 统计自己场上表侧表示的「DDD」怪兽数量。
	local count2=Duel.GetMatchingGroupCount(s.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 确认发动条件：魔法陷阱区有空位、存在可选择的契约书、且场上有DDD怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and count1>0 and count2>0 end
	-- 计算实际可选择的对象张数：取魔法陷阱区空格数、契约书可用数、DDD怪兽数的最小值。
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),count1,count2)
	-- 提示玩家选择要放置到场上的契约书卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家从墓地/除外区选择1~ct张满足条件的「契约书」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.tffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil,tp)
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if gg:GetCount()>0 then
		-- 若选择了墓地中的契约书，登记“卡将离开墓地”的操作信息，供相关效果响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,gg:GetCount(),0,0)
	end
end
-- ②效果处理：将对象契约书表侧放置到自己魔法陷阱区；若可用区域不足，则从对象中选取可放置的，剩余除外区的契约书按规则送墓。
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中作为②效果对象的卡片组。
	local g=Duel.GetTargetsRelateToChain()
	-- 获取自己当前魔法陷阱区的可用空格数。
	local sct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local ct=math.min(g:GetCount(),sct)
	local pg=g
	if ct<=0 then
		pg=Group.CreateGroup()
	elseif g:GetCount()>ct then
		-- 当对象数超过可用区域时，提示玩家选择要实际放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		pg=g:Select(tp,ct,ct,nil)
		g:Sub(pg)
	else
		g=Group.CreateGroup()
	end
	-- 遍历所有要放置的契约书卡片。
	for tc in aux.Next(pg) do
		-- 将契约书移动到自己魔法陷阱区并表侧放置，同时立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if sg:GetCount()>0 then
		-- 因区域不足而未被放置的除外区契约书，按规则送入墓地。
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
