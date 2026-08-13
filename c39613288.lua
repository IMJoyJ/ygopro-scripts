--ダーク・スプレマシー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己墓地的「暗黑融合」以及有那个卡名记述的魔法卡数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的最多5只「英雄」怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 定义暗黑霸权的效果注册函数，创建并注册两个效果：①为发动魔法卡无效对方场上的卡；②为墓地中除外自身并将英雄怪兽返回卡组的诱发即时效果。
function s.initial_effect(c)
	-- 将暗黑融合（94820406）登记为暗黑霸权效果文本中记载的卡，用于后续通过aux.IsCodeListed判断哪些魔法卡记载了该卡名。
	aux.AddCodeList(c,94820406)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以最多有自己墓地的「暗黑融合」以及有那个卡名记述的魔法卡数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的最多5只「英雄」怪兽为对象才能发动。那些怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：这张卡不是在“这个回合被送去墓地”的情况下才能发动（即送去墓地的回合不能发动）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将这张卡自身从墓地除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数s.cfilter，用于统计自己墓地中记载了「暗黑融合」的魔法卡数量，这些卡的数量决定①效果可选择的对方卡片数量上限。
function s.cfilter(c)
	-- 判断一张卡是否为「暗黑融合」本身或效果文本中记载了「暗黑融合」的魔法卡。
	return (c:IsCode(94820406) or aux.IsCodeListed(c,94820406)) and c:IsType(TYPE_SPELL)
end
-- ①效果的目标处理函数：计算可选数量ct，选择对方场上1至ct张表侧表示且能被无效的卡作为对象，并设置无效效果的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己墓地中满足s.cfilter的魔法卡数量ct，作为①效果可选择对方卡片的数量上限。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 连锁中检查候选对象：该卡必须在场上、是对方控制，且能够被无效化。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 发动合法性检查：自己墓地存在符合条件的魔法卡，且对方场上有至少1张可被无效的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 显示选择提示消息，提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方场上选择1至ct张可被无效的表侧表示卡，并将选择结果设为连锁对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息为无效效果，对象为g，数量为g中的卡数，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果处理：对仍与效果关联的每个对象卡，使其怪兽效果无效化、效果无效化直到回合结束；若对象是陷阱怪兽，则将其怪兽化效果也无效。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁对应的所有对象卡，即发动①效果时选择的卡。
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历所有对象卡，逐张进行无效化处理。
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与对象卡相关的连锁效果无效化，并在变里侧或回合结束时重置。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 定义②效果的对象过滤条件：表侧表示的「英雄」怪兽，且能够返回卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果的目标处理函数：选择自己墓地或除外状态的1至5只符合条件的「英雄」怪兽作为对象，并设置回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- ②发动合法性检查：自己墓地或除外状态存在除自身外至少1只可选择的「英雄」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 显示选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地或除外状态中1至5只符合条件的「英雄」怪兽，并设为连锁对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,5,nil)
	-- 设置当前连锁的操作信息为回卡组，对象为选中的怪兽，数量为选中数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：若对象卡仍与效果关联且不受王家长眠之谷效果影响，则将它们送回持有者卡组并洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁对应的对象卡组，即②效果发动时选择的英雄怪兽。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 and not g:IsExists(Card.IsHasEffect,1,nil,EFFECT_NECRO_VALLEY) then
		-- 将对象怪兽以效果方式送回持有者卡组，并标记需要洗切卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
