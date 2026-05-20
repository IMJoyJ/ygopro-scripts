--星満ちる新世壊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有「维萨斯-斯塔弗罗斯特」存在，自己怪兽在1回合各有1次不会被战斗破坏。
-- ②：自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，自己结束阶段，以自己墓地1只怪兽为对象才能发动。那只怪兽回到卡组。自己场上有同调怪兽调整存在的场合，也能不回到卡组加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①效果（战斗破坏抗性）和②效果（结束阶段回收墓地怪兽）。
function s.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」注册到该卡的关联卡片密码列表中，用于支持相关检索或效果检测。
	aux.AddCodeList(c,56099748)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有「维萨斯-斯塔弗罗斯特」存在，自己怪兽在1回合各有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indcon)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ②：自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，自己结束阶段，以自己墓地1只怪兽为对象才能发动。那只怪兽回到卡组。自己场上有同调怪兽调整存在的场合，也能不回到卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「维萨斯-斯塔弗罗斯特」。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- ①效果的适用条件：自己场上存在「维萨斯-斯塔弗罗斯特」。
function s.indcon(e)
	-- 检查自己场上是否存在表侧表示的「维萨斯-斯塔弗罗斯特」。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 设置不会被破坏的次数：1回合1次不会被战斗破坏。
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- ②效果的发动条件：自己的结束阶段，且自己场上存在「维萨斯-斯塔弗罗斯特」。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的结束阶段。
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END
		-- 检查自己场上是否存在表侧表示的「维萨斯-斯塔弗罗斯特」。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：墓地的怪兽，且可以回到卡组，或者在满足条件时可以加入手卡。
function s.filter(c,check)
	return c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or check and c:IsAbleToHand())
end
-- 过滤条件：场上表侧表示的同调怪兽调整。
function s.chkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER)
end
-- ②效果的发动准备：检查场上是否存在同调调整，选择墓地1只怪兽作为对象，并设置效果处理信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在表侧表示的同调怪兽调整。
	local check=Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,check) end
	-- 检查墓地是否存在符合条件的怪兽以满足效果发动要求。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,check) end
	-- 向玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地1只怪兽作为效果的对象并进行取对象操作。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,check)
	-- 设置效果处理信息：有1张卡将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的效果处理：获取对象怪兽，进行王家之谷检测，根据场上是否存在同调调整让玩家选择将其回到卡组或加入手卡。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 进行「王家长眠之谷」的无效化检测。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 过滤确认对象怪兽不受「王家长眠之谷」的影响。
		if not aux.NecroValleyFilter()(tc) then return end
		local opt=0
		local b1=tc:IsAbleToDeck()
		-- 检查是否满足“加入手卡”的条件：对象怪兽可以加入手卡，且自己场上存在同调怪兽调整。
		local b2=tc:IsAbleToHand() and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil)
		if b1 and not b2 then
			opt=1
		elseif b2 and not b1 then
			opt=2
		elseif b1 and b2 then
			-- 让玩家选择将对象怪兽回到卡组还是加入手卡。
			opt=Duel.SelectOption(tp,1193,1190)+1
		end
		if opt==1 then
			-- 将对象怪兽送回卡组并洗牌。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		elseif opt==2 then
			-- 将对象怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
