--狂嵐異解△プルートニオン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，把手卡的这张卡和手卡1张「异解△」卡给对方观看才能发动。那2张里侧除外，自己抽2张。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把7张卡里侧除外。
-- ③：自己·对方回合1次，可以发动。自己的除外状态（里侧）的1只「异解△」怪兽回到卡组。那之后，可以让和那只怪兽属性相同的对方场上1只怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片初始效果：①展示手卡并里侧除外抽2张；②召唤·特殊召唤成功时卡组顶端里侧除外7张卡；③除外状态里侧怪兽回到卡组并选对方同属性怪兽回到卡组
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方回合，把手卡的这张卡和手卡1张「异解△」卡给对方观看才能发动。那2张里侧除外，自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"回到卡组"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMING_DRAW_PHASE+TIMING_END_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把7张卡里侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合1次，可以发动。自己的除外状态（里侧）的1只「异解△」怪兽回到卡组。那之后，可以让和那只怪兽属性相同的对方场上1只怪兽回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回到卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中未公开且可里侧除外的「异解△」卡
function s.costfilter(c,tp)
	return c:IsSetCard(0x1ed) and not c:IsPublic() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- ①效果的cost：把手卡的这张卡和手卡1张「异解△」卡给对方观看
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身未公开且可里侧除外，且手卡存在自身以外可里侧除外的未公开「异解△」卡
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) and c:IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 提示选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张自身以外未公开的「异解△」卡
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),tp):GetFirst()
	-- 向对方展示选择的卡片
	Duel.ConfirmCards(1-tp,sc)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「狂岚异解△普戮托尼翁」的效果被观看"
	sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「狂岚异解△普戮托尼翁」的效果被观看"
end
-- ①效果的目标：检查是否可以抽2张卡并设置抽卡操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置抽2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ①效果的处理：展示的2张卡里侧除外并抽2张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	if fg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN,REASON_EFFECT)==2
		-- 将那2张卡以里侧表示除外
		and Duel.Remove(fg,POS_FACEDOWN,REASON_EFFECT)~=0 then
		-- 遍历被里侧除外的卡片以添加客户端提示
		for tc in aux.Next(fg) do
			if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))  --"因「狂岚异解△普戮托尼翁」①被里侧除外"
			end
		end
		-- 自身从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- ②效果的目标：获取卡组顶端7张卡并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自身卡组顶端的7张卡
	local dg=Duel.GetDecktopGroup(tp,7)
	if chk==0 then return true end
	-- 设置除外卡组顶端7张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果的处理：将卡组顶端的7张卡里侧除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身卡组顶端的7张卡
	local dg=Duel.GetDecktopGroup(tp,7)
	if dg and dg:GetCount()>0 then
		-- 禁用下一次操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组顶端的卡以里侧表示除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被里侧除外的卡片以添加客户端提示
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,6))  --"因「狂岚异解△普戮托尼翁」②被里侧除外"
				end
			end
		end
	end
end
-- 过滤除外状态里侧表示且可以回到卡组的「异解△」怪兽
function s.tdfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤对方场上表侧表示、具有相同属性且可以回到卡组的怪兽
function s.tdfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToDeck()
end
-- ③效果的目标：检查除外区是否存在目标怪兽并设置回到卡组操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的除外区是否存在里侧表示且可回到卡组的「异解△」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置将除外区1张卡回到卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的处理：让除外状态里侧表示的1只「异解△」怪兽回到卡组，之后可选对方场上同属性怪兽回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从除外区选择1只里侧表示的「异解△」怪兽
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中的卡片被选为对象的效果
		Duel.HintSelection(g)
		-- 向对方确认选中的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 将选中的怪兽送回卡组洗切
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			local att=g:GetFirst():GetAttribute()
			-- 检查对方场上是否存在与该怪兽相同属性且可回到卡组的表侧表示怪兽
			if Duel.IsExistingMatchingCard(s.tdfilter2,tp,0,LOCATION_MZONE,1,nil,att)
				-- 询问玩家是否让怪兽回到卡组
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否让怪兽回到卡组？"
				-- 提示选择要返回卡组的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
				-- 从对方场上选择1只相同属性的表侧表示怪兽
				local sg=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,0,LOCATION_MZONE,1,1,nil,att)
				if sg:GetCount()>0 then
					-- 中断当前效果，使之后的处理不同时进行
					Duel.BreakEffect()
					-- 显示对方怪兽被选中的效果
					Duel.HintSelection(sg)
					-- 将选中的对方怪兽送回卡组洗切
					Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end
