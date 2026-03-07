--ダーク・スプレマシー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己墓地的「暗黑融合」以及有那个卡名记述的魔法卡数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的最多5只「英雄」怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片效果，创建两个效果，分别为①和②效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载着「暗黑融合」（卡号94820406）
	aux.AddCodeList(c,94820406)
	-- ①：以最多有自己墓地的「暗黑融合」以及有那个卡名记述的魔法卡数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
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
	-- 效果发动条件：这张卡在本回合没有送去墓地
	e2:SetCondition(aux.exccon)
	-- 效果发动费用：将这张卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的卡是否为「暗黑融合」或记载着「暗黑融合」的魔法卡
function s.cfilter(c)
	-- 判断卡是否为「暗黑融合」或记载着「暗黑融合」的魔法卡且为魔法卡类型
	return (c:IsCode(94820406) or aux.IsCodeListed(c,94820406)) and c:IsType(TYPE_SPELL)
end
-- 效果目标选择函数，用于选择对方场上的表侧表示卡进行无效化
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己墓地中的「暗黑融合」或记载着「暗黑融合」的魔法卡数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判断当前是否为选择目标阶段，目标必须在场上且为对方控制
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 判断是否满足发动条件：场上存在可无效的卡且自己墓地有「暗黑融合」或记载着「暗黑融合」的魔法卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择最多与墓地「暗黑融合」数量相同的对方场上表侧表示卡
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁操作信息，指定将要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理函数，对选中的卡进行无效化处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的卡组
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历选中的卡组进行处理
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使目标卡的连锁无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标卡的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标卡的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使目标陷阱怪兽无效
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
-- 过滤函数，用于判断是否为「英雄」族且在墓地或除外状态的怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果目标选择函数，用于选择自己墓地或除外状态的「英雄」怪兽
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 判断是否满足发动条件：自己墓地或除外状态有「英雄」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择最多5只自己墓地或除外状态的「英雄」怪兽
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,5,nil)
	-- 设置连锁操作信息，指定将要返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理函数，将选中的「英雄」怪兽送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的卡组
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 and not g:IsExists(Card.IsHasEffect,1,nil,EFFECT_NECRO_VALLEY) then
		-- 将卡组中的卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
