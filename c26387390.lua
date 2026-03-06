--ジャンク・シグナル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下选择1个发动。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ●把自己场上1只怪兽解放才能发动。除那只怪兽外的1只「废品战士」「星尘龙」或者有那其中任意种的卡名记述的怪兽从自己的手卡·卡组·墓地特殊召唤。
-- ●对方连锁自己的同调怪兽的效果的发动把效果发动时才能发动。那个对方的效果无效。
local s,id,o=GetID()
-- 初始化效果，注册卡名代码列表并创建发动效果
function s.initial_effect(c)
	-- 记录该卡具有「废品战士」和「星尘龙」的卡名记述
	aux.AddCodeList(c,60800381,44508094)
	-- ①：可以从以下选择1个发动。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_CHAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足解放怪兽并特殊召唤的条件
function s.resfilter(c,e,tp)
	-- 检查手卡·卡组·墓地是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
		-- 检查场上是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，用于筛选「废品战士」或「星尘龙」及其记述的怪兽
function s.filter(c,e,tp,fid)
	-- 判断该怪兽是否为「废品战士」或「星尘龙」或其记述的怪兽
	return (aux.IsCodeOrListed(c,60800381) or aux.IsCodeOrListed(c,44508094))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (fid==nil or c:GetFieldID()~=fid)
end
-- 处理效果发动的选择，判断是否可以发动两种效果之一
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足解放条件的怪兽
	local b1=Duel.CheckReleaseGroup(tp,s.resfilter,1,nil,e,tp)
	-- 获取当前连锁序号
	local ch=Duel.GetCurrentChain()
	local b2=false
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	local tse=nil
	if ch>1 then
		-- 获取上一个连锁的效果和玩家
		local se,p=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 获取当前连锁的效果
		tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
		-- 获取当前连锁的玩家
		local tep=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER)
		-- 判断是否满足对方连锁同调怪兽效果的条件
		b2=se and se:GetHandler():IsType(TYPE_SYNCHRO) and se:IsActiveType(TYPE_MONSTER) and p==tp and tep==1-tp and Duel.IsChainDisablable(ev)
	end
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动效果
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"特殊召唤"
		{b2,aux.Stringid(id,2),2})  --"效果无效"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 选择要解放的怪兽
		local cost_card=Duel.SelectReleaseGroup(tp,s.resfilter,1,1,nil,e,tp):GetFirst()
		-- 解放所选怪兽作为发动代价
		Duel.Release(cost_card,REASON_COST)
		local fid=cost_card:GetFieldID()
		e:SetLabel(1,fid)
		-- 设置操作信息，表示将要特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE)
		if tse then
			local og=Group.FromCards(tse:GetHandler())
			-- 设置操作信息，表示将要无效对方效果
			Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
		end
	end
end
-- 处理效果发动后的实际操作，包括设置不能特殊召唤的效果和执行特殊召唤或无效效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●把自己场上1只怪兽解放才能发动。除那只怪兽外的1只「废品战士」「星尘龙」或者有那其中任意种的卡名记述的怪兽从自己的手卡·卡组·墓地特殊召唤。●对方连锁自己的同调怪兽的效果的发动把效果发动时才能发动。那个对方的效果无效。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e0,tp)
	local op,fid=e:GetLabel()
	if op==1 then
		-- 检查场上是否有足够的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,fid)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		-- 获取当前连锁序号
		local ch=Duel.GetCurrentChain()
		-- 使上一个连锁的效果无效
		Duel.NegateEffect(ch-1)
	end
end
-- 设置不能特殊召唤的效果限制，仅限非同调怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
