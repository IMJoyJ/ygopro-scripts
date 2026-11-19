--黒き竜のエクレシア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：记录「阿不思的落胤」卡名并设置同调召唤手续，注册暂时除外特召的①效果与墓地回收3张卡的②效果，各限制1回合1次。
function s.initial_effect(c)
	-- 记录这张卡的卡文上记载了「阿不思的落胤」的卡名。
	aux.AddCodeList(c,68468459)
	-- 为这张卡添加同调召唤手续：1只调整加上1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
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
-- ①效果的发动条件判定：检查当前是否处于自己或对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前决斗阶段是否为主要阶段1或主要阶段2。
	return Duel.IsMainPhase()
end
-- 过滤函数：判断怪兽是否为「阿不思的落胤」或卡文记述了其卡名的4星以下怪兽，且能被特殊召唤。
function s.spfilter(c,e,tp)
	-- 检查卡片是否为「阿不思的落胤」或记载了其卡名的4星以下怪兽，且可以常规特殊召唤。
	return (c:IsCode(68468459) or (c:IsLevelBelow(4) and aux.IsCodeListed(c,68468459))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数（可行性检测部分）：检查这张卡离场后自己怪兽区有空位、自身可除外，且卡组或墓地存在可特召怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动可行性检测：检查这张卡离场后自己主要怪兽区是否至少有1个可用空位。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		and c:IsAbleToRemove()
		-- 且检查自己墓地或卡组中是否存在至少1只满足条件的待特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：预计将场上的这张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置操作信息：预计从自己的墓地或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- ①效果的效果处理函数：将这张卡暂时除外至结束阶段并注册归还效果，随后从卡组或墓地选1只满足条件的怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 若这张卡仍与当前连锁有联系，则以效果暂时将其除外并确认除外成功。
	if c:IsRelateToChain() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))  --"直到结束阶段除外"
			-- 这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 为自己注册一个在结束阶段触发的全局持续效果，用于使暂时除外的这张卡返回场上。
			Duel.RegisterEffect(e1,tp)
		end
		-- 检查自己怪兽区域当前是否仍有可用空位。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 向自己发送选择提示，提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己的墓地或卡组选择1只不受王家长眠之谷影响的满足条件怪兽。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 归还场上效果的触发条件判定：核对被暂时除外的卡片是否仍保有对应的场域标识，否则销毁该临时效果。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 归还场上效果的处理函数：将暂时除外的这张卡返回到场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的这张卡返回到原本场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- 过滤函数：判断卡片是否为自己墓地或表侧除外状态的8星融合怪兽，且同时存在场上可成为对象并回卡组的卡。
function s.tdfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevel(8) and c:IsType(TYPE_FUSION)
		-- 且检查双方场上是否存在至少1张可成为对象并返回卡组的卡。
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ②效果的对象选择与目标处理函数：分别选择自己墓地或除外状态的1只8星融合怪兽和场上1张卡为对象，并申报共3张卡回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 发动可行性检测：检查存在符合条件的8星融合怪兽对象及场上对象，且墓地的这张卡也能返回卡组。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) and c:IsAbleToDeck() end
	-- 向自己发送选择提示，提示玩家选择墓地或除外区中要返回卡组的8星融合怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己的墓地或除外区选择1只8星融合怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	-- 向自己发送选择提示，提示玩家选择场上要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方场上选择1张可返回卡组的卡作为对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	g1:AddCard(c)
	-- 设置操作信息：预计将选中的2张对象卡与墓地的这张卡共3张返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,3,0,0)
end
-- ②效果的效果处理函数：若这张卡及2张对象卡均与连锁有联系且不受王家长眠之谷限制能回卡组，则将这3张卡一起洗回卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 获取当前连锁中仍与效果有联系的所有对象卡片组。
	local g=Duel.GetTargetsRelateToChain()
	g:AddCard(c)
	-- 检查包含这张卡在内的3张卡是否全部满足不受王家长眠之谷影响且能回卡组的条件，否则中止处理。
	if g:FilterCount(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)~=3 then return end
	-- 将这3张卡以效果送回各自持有者的卡组或额外卡组并标记洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
