--妖眼の相剣師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，效果被无效化的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，可以从以那些怪兽从哪里特殊召唤来对应的以下效果选择1个发动。
-- ●手卡：从手卡把1只怪兽特殊召唤。
-- ●卡组：自己从卡组抽2张。
-- ●额外卡组：从额外卡组特殊召唤的那些怪兽之内的1只破坏。
function c62849088.initial_effect(c)
	-- ①：自己·对方的主要阶段，效果被无效化的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62849088,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,62849088)
	e1:SetCondition(c62849088.spcon)
	e1:SetTarget(c62849088.sptg)
	e1:SetOperation(c62849088.spop)
	c:RegisterEffect(e1)
	-- 为单张卡片注册一个合并的延迟特殊召唤成功事件监听器，用于处理对方特殊召唤怪兽的场合。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,62849088,EVENT_SPSUMMON_SUCCESS)
	-- ②：对方把怪兽特殊召唤的场合，可以从以那些怪兽从哪里特殊召唤来对应的以下效果选择1个发动。●手卡：从手卡把1只怪兽特殊召唤。●卡组：自己从卡组抽2张。●额外卡组：从额外卡组特殊召唤的那些怪兽之内的1只破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62849088,1))  --"选择效果发动"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,62849089)
	e2:SetCondition(c62849088.descon)
	e2:SetTarget(c62849088.destg)
	e2:SetOperation(c62849088.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且效果被无效的效果怪兽
function c62849088.cfilter(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
-- 效果①的发动条件：自己或对方的主要阶段，且场上有效果被无效的怪兽存在
function c62849088.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查场上是否存在至少1只满足过滤条件（表侧表示且效果被无效）的效果怪兽
		and Duel.IsExistingMatchingCard(c62849088.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c62849088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤
function c62849088.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：对方把怪兽特殊召唤
function c62849088.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 过滤条件：原本是怪兽卡，且由对方从指定位置（手卡、卡组或额外卡组）特殊召唤
function c62849088.spfilter(c,loc,tp)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsSummonLocation(loc) and c:IsSummonPlayer(1-tp)
end
-- 过滤条件：对方从额外卡组特殊召唤且当前存在于怪兽区域的怪兽
function c62849088.desfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
-- 效果②的发动准备：根据对方特殊召唤怪兽的来源，判断可行分支，让玩家选择并设置对应的操作信息
function c62849088.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断分支1（手卡）是否满足：对方从手卡特殊召唤了怪兽，且自己场上有可用的怪兽区域
	local b1=eg:IsExists(c62849088.spfilter,1,nil,LOCATION_HAND,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己手卡存在可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false)
	-- 判断分支2（卡组）是否满足：对方从卡组特殊召唤了怪兽，且自己可以从卡组抽2张卡
	local b2=eg:IsExists(c62849088.spfilter,1,nil,LOCATION_DECK,tp) and Duel.IsPlayerCanDraw(tp,2)
	local b3=eg:IsExists(c62849088.spfilter,1,nil,LOCATION_EXTRA,tp)
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(62849088,2)  --"从手卡把1只怪兽特殊召唤"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(62849088,3)  --"自己从卡组抽2张"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(62849088,4)  --"选从额外卡组特殊召唤的那1只怪兽破坏"
		opval[off-1]=3
		off=off+1
	end
	-- 让玩家从满足条件的选项中选择一个发动
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	if opval[op]==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 分支1（手卡）：设置特殊召唤手卡怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif opval[op]==2 then
		e:SetCategory(CATEGORY_DRAW)
		-- 分支2（卡组）：设置效果处理的对象玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 分支2（卡组）：设置效果处理的参数为2（抽卡数量）
		Duel.SetTargetParam(2)
		-- 分支2（卡组）：设置抽卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	else
		e:SetCategory(CATEGORY_DESTROY)
		local g=eg:Filter(c62849088.desfilter,nil,tp)
		-- 分支3（额外卡组）：将对方从额外卡组特殊召唤的怪兽设为效果处理的目标
		Duel.SetTargetCard(g)
		-- 分支3（额外卡组）：设置破坏怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果②的效果处理：根据玩家选择的分支，执行对应的特殊召唤、抽卡或破坏效果
function c62849088.desop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 分支1（手卡）：若自己场上没有可用的怪兽区域，则不处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 分支1（手卡）：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 分支1（手卡）：从手卡选择1只可以特殊召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false)
		if g:GetCount()>0 then
			-- 分支1（手卡）：将选择的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif sel==2 then
		-- 分支2（卡组）：获取抽卡的目标玩家和抽卡数量
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 分支2（卡组）：让目标玩家因效果抽卡
		Duel.Draw(p,d,REASON_EFFECT)
	else
		-- 分支3（额外卡组）：获取并过滤出仍与效果相关且确实是从额外卡组特殊召唤的怪兽
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsSummonLocation,nil,LOCATION_EXTRA)
		if g:GetCount()>0 then
			if g:GetCount()>1 then
				-- 分支3（额外卡组）：若有多只，提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				g=g:Select(tp,1,1,nil)
			end
			-- 分支3（额外卡组）：为选中的破坏目标显示选择动画
			Duel.HintSelection(g)
			-- 分支3（额外卡组）：将选中的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
