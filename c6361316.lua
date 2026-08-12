--WAKE CUP！ クロ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「睡醒一杯！玉露茶」以外的1只风属性反转怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡反转的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：自己·对方回合，以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的检索及丢弃效果、②的反转盖放效果、③的自由时点转表效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「睡醒一杯！玉露茶」以外的1只风属性反转怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.postg2)
	e3:SetOperation(s.posop2)
	c:RegisterEffect(e3)
end
-- ①效果的Cost：检查手卡的这张卡是否未公开（即可以给对方观看）
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：卡组中「睡醒一杯！玉露茶」以外的风属性反转怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsType(TYPE_FLIP) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- ①效果的Target：检查卡组中是否存在符合条件的怪兽，并设置检索和丢弃手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「睡醒一杯！玉露茶」以外的1只风属性反转怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①效果的Operation：从卡组检索符合条件的怪兽加入手卡并给对方确认，若成功加入则选1张手卡丢弃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的风属性反转怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 提示玩家选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 从手卡选择1张可以丢弃的卡
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			if dg:GetCount()>0 then
				-- 中断效果处理，使后续的丢弃手牌处理与检索处理不视为同时进行
				Duel.BreakEffect()
				-- 将选中的手牌送去墓地（丢弃）
				Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
-- 过滤条件：场上表侧表示且可以变成里侧守备表示的怪兽
function s.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的Target：检查并选择场上1只其他的表侧表示怪兽作为对象，设置改变表示形式的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.setfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在除自身以外的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只其他的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置操作信息：改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的Operation：将作为对象的怪兽变成里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ③效果的Target：检查并选择场上1只里侧守备表示怪兽作为对象，设置改变表示形式的操作信息
function s.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	-- 检查场上是否存在里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择里侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择场上1只里侧守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ③效果的Operation：将作为对象的里侧守备表示怪兽变成表侧守备表示
function s.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将目标怪兽变成表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
