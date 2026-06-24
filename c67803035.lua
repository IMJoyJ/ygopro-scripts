--破械転生
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①发动时检索满足条件的魔法卡加入手牌；②场地区域放置时可选择墓地的卡返回卡组并破坏场上怪兽
function s.initial_effect(c)
	-- 记录该卡与编号为27412542的卡有关联
	aux.AddCodeList(c,27412542)
	-- 效果①：发动时检索满足条件的魔法卡加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：场地区域放置时可选择墓地的卡返回卡组并破坏场上怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 检索过滤器函数，用于筛选可以加入手牌的卡（非自身且为特定编号或特定属性的魔法卡）
function s.thfilter(c)
	return not c:IsCode(id) and (c:IsCode(27412542) or c:IsSetCard(0x130) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 发动效果①的处理函数，从卡组中检索满足条件的卡加入手牌并确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足检索条件的卡组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的卡且玩家选择发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方能看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 返回卡组过滤器函数，用于筛选可以返回卡组的卡（非自身且为特定属性）
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x130) and c:IsAbleToDeck()
end
-- 效果②的目标选择函数，判断是否满足目标条件
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) and chkc~=e:GetHandler() end
	-- 判断是否满足效果②的目标选择条件
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡组中的卡返回卡组
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,e:GetHandler())
	-- 设置操作信息，记录将要返回卡组的卡数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的处理函数，将选中的卡返回卡组并可能破坏场上怪兽
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的卡组
	local g=Duel.GetTargetsRelateToChain()
	-- 判断是否有卡被送入卡组且实际送入卡组
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 统计实际送入卡组或额外卡组的卡数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 判断场上有怪兽存在且玩家选择发动效果
		if ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,aux.ExceptThisCard(e))
			-- 玩家确认是否发动破坏效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果处理，使后续处理错时点
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上满足条件的怪兽进行破坏
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,ct,aux.ExceptThisCard(e))
			-- 显示选中的卡被作为对象的动画效果
			Duel.HintSelection(sg)
			-- 将选中的卡破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
