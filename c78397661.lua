--黒き竜のエクレシア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：登记卡名记述、设置同调召唤手续和苏生限制，并注册①的诱发即时效果（诱发即时、取对象以外的特殊召唤·除外）和②的起动效果（回卡组）
function s.initial_effect(c)
	-- 登记这张卡上记述着「阿不思的落胤」（卡号68468459）这一事实，供卡名记述判定使用
	aux.AddCodeList(c,68468459)
	-- 为这张卡设置同调召唤手续：1只调整＋1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果发动条件的判定函数：确认当前是主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己或对方的主要阶段，作为发动条件
	return Duel.IsMainPhase()
end
-- 特殊召唤对象过滤函数：筛选卡组·墓地中符合条件的怪兽
function s.spfilter(c,e,tp)
	-- 过滤条件：卡名是「阿不思的落胤」或者文本中有其卡名记述、等级4星以下、且可以被特殊召唤的怪兽
	return aux.IsCodeOrListed(c,68468459) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标函数：发动可能时进行合法性检查，并设置除外与特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动可能性检查：确认这张卡离场后场上至少有1个可用的怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		and c:IsAbleToRemove()
		-- 并且自己的卡组·墓地存在至少1只满足特殊召唤过滤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：确定这张卡将被除外（数量1张）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置操作信息：预计从自己的卡组·墓地特殊召唤1只怪兽（处理时才能确定对象）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- ①效果的处理函数：把这张卡暂时除外，注册结束阶段返回场上的持续效果，然后从卡组·墓地特殊召唤1只符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 确认这张卡仍与连锁相关后，以效果原因将其暂时除外（REASON_TEMPORARY表示结束阶段可以返回）
	if c:IsRelateToChain() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))  --"直到结束阶段除外"
			-- 从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 把「结束阶段时这张卡返回场上」的持续效果注册到全局环境
			Duel.RegisterEffect(e1,tp)
		end
		-- 确认自己场上有可用的怪兽区后再进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 向玩家提示选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己的卡组·墓地选择1只满足条件且不受王家长眠之谷影响的怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 把选择的怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 结束阶段返回效果的发动条件：检查这张卡上记录的标识是否与注册时一致，不一致则重置该效果，一致才执行返回
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段的处理函数：把暂时除外的这张卡返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 把这张卡从除外状态返回到场上（返回离场前的表示形式）
	Duel.ReturnToField(e:GetLabelObject())
end
-- ②效果的对象过滤函数：筛选自己墓地·除外状态的8星融合怪兽
function s.tdfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevel(8) and c:IsType(TYPE_FUSION)
		-- 并且确认双方场上存在至少1张可以回到卡组的卡作为另一个对象
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ②效果的目标函数：确认这张卡在墓地且可以回到卡组，选择1只8星融合怪兽和场上1张卡作为对象，并设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 发动可能性检查：自己的墓地·除外状态存在1只8星融合怪兽可以作为对象，并且这张卡自身可以回到卡组
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) and c:IsAbleToDeck() end
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己的墓地·除外状态的1只8星融合怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方场上1张可以回到卡组的卡作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	g1:AddCard(c)
	-- 设置操作信息：确定这2张对象卡和这张卡共3张将回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,3,0,0)
end
-- ②效果的处理函数：确认对象卡均与连锁相关后，把那2张卡和这张卡共3张送回卡组并洗切
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 取得与当前连锁相关的对象卡组（即选择的2张卡）
	local g=Duel.GetTargetsRelateToChain()
	g:AddCard(c)
	-- 检查3张卡都可以回到卡组且不受王家长眠之谷影响，否则不处理
	if g:FilterCount(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)~=3 then return end
	-- 把那2张卡和这张卡以效果原因返回卡组并洗切卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
