--一色万骨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己墓地的通常怪兽种类的以下效果各适用。
-- ●1种类以上：这个回合中，自己场上的通常怪兽的攻击力上升800。
-- ●2种类以上：场上1只效果怪兽的效果直到回合结束时无效。
-- ●3种类以上：这个回合中，自己场上的通常怪兽不会被效果破坏。
-- ●4种类以上：场上1只效果怪兽回到卡组。
-- ●5种类以上：从卡组把1张「一色万骨」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将本卡卡名（一色万骨）注册到本卡的关联卡片列表中
	aux.AddCodeList(c,id)
	-- 这个卡名的卡在1回合只能发动1张。①：自己墓地的通常怪兽种类的以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：是否为通常怪兽
function s.cfilter(c)
	return c:IsAllTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 效果发动的靶向与合法性检测函数，检查自己墓地是否存在通常怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地的所有通常怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetCount()>0 end
end
-- 过滤条件：是否为场上表侧表示、可返回卡组的效果怪兽
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤条件：是否为卡组中可加入手牌的「一色万骨」
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
-- 效果处理的核心执行函数，根据自己墓地通常怪兽的种类数量依次适用对应效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己墓地的所有通常怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local op=g:GetClassCount(Card.GetCode)
	if op>0 then
		-- ●1种类以上：这个回合中，自己场上的通常怪兽的攻击力上升800。●2种类以上：场上1只效果怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.atktg)
		e1:SetValue(800)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使自己场上通常怪兽攻击力上升的效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 判断墓地通常怪兽是否在2种类以上，且场上是否存在可以无效的效果怪兽
	if op>1 and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		-- 中断当前效果处理，使后续的无效效果与前面的效果不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要无效的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择场上1只表侧表示的效果怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 闪烁显示所选择的怪兽
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 无效与该怪兽相关的连锁
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ●2种类以上：场上1只效果怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- ●2种类以上：场上1只效果怪兽的效果直到回合结束时无效。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
	if op>2 then
		-- ●3种类以上：这个回合中，自己场上的通常怪兽不会被效果破坏。●4种类以上：场上1只效果怪兽回到卡组。●5种类以上：从卡组把1张「一色万骨」加入手卡。
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e5:SetTargetRange(LOCATION_MZONE,0)
		e5:SetTarget(s.atktg)
		e5:SetValue(1)
		e5:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使自己场上通常怪兽不会被效果破坏的效果
		Duel.RegisterEffect(e5,tp)
	end
	-- 判断墓地通常怪兽是否在4种类以上，且场上是否存在可以返回卡组的效果怪兽
	if op>3 and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		-- 获取场上所有满足返回卡组条件的效果怪兽
		local sg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的返回卡组效果与前面的效果不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要返回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local ssg=sg:Select(tp,1,1,nil)
			-- 闪烁显示所选择要返回卡组的怪兽
			Duel.HintSelection(ssg)
			-- 将选中的怪兽返回持有者卡组并洗牌
			Duel.SendtoDeck(ssg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	if op>4 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「一色万骨」
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的检索效果与前面的效果不视为同时处理
			Duel.BreakEffect()
			-- 将选中的「一色万骨」加入玩家手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡片
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤条件：用于确定攻击力上升和效果破坏抗性仅适用于自己场上表侧表示的通常怪兽
function s.atktg(e,c)
	return c:IsAllTypes(TYPE_NORMAL+TYPE_MONSTER) and c:IsFaceup()
end
