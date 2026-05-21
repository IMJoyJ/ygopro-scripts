--星遺物の傀儡
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或者表侧守备表示。
-- ②：让自己墓地1只「机怪虫」怪兽回到卡组，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c89320376.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89320376.target)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或者表侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetDescription(aux.Stringid(89320376,0))  --"里侧表示怪兽变成表侧表示"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c89320376.cost)
	e2:SetTarget(c89320376.postg1)
	e2:SetOperation(c89320376.posop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(89320376,1))  --"表侧表示怪兽变成里侧表示"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetCost(c89320376.poscost)
	e3:SetTarget(c89320376.postg2)
	e3:SetOperation(c89320376.posop2)
	c:RegisterEffect(e3)
end
-- 检查并注册1回合只能使用1次其中任意1个效果的玩家标识的Cost函数
function c89320376.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否尚未发动过该卡的效果
	if chk==0 then return Duel.GetFlagEffect(tp,89320376)==0 end
	-- 给玩家注册本回合已使用该卡效果的标识
	Duel.RegisterFlagEffect(tp,89320376,RESET_PHASE+PHASE_END,0,1)
end
-- 卡片发动时的效果选择与目标确认函数
function c89320376.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return c89320376.postg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		else
			return c89320376.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		end
	end
	if chk==0 then return true end
	local b1=c89320376.cost(e,tp,eg,ep,ev,re,r,rp,0) and c89320376.postg1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=c89320376.poscost(e,tp,eg,ep,ev,re,r,rp,0) and c89320376.postg2(e,tp,eg,ep,ev,re,r,rp,0)
	-- 若有可发动的效果，询问玩家在卡片发动时是否同时发动其中一个效果
	if (b1 or b2) and Duel.SelectYesNo(tp,94) then
		local op=0
		if b1 and b2 then
			-- 让玩家选择发动效果①（里侧变表侧）或效果②（表侧变里侧）
			op=Duel.SelectOption(tp,aux.Stringid(89320376,0),aux.Stringid(89320376,1))  --"里侧表示怪兽变成表侧表示/表侧表示怪兽变成里侧表示"
		elseif b1 then
			-- 让玩家选择发动效果①（里侧变表侧）
			op=Duel.SelectOption(tp,aux.Stringid(89320376,0))  --"里侧表示怪兽变成表侧表示"
		else
			-- 让玩家选择发动效果②（表侧变里侧）
			op=Duel.SelectOption(tp,aux.Stringid(89320376,1))+1  --"表侧表示怪兽变成里侧表示"
		end
		e:SetLabel(op)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		if op==0 then
			c89320376.cost(e,tp,eg,ep,ev,re,r,rp,1)
			c89320376.postg1(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetOperation(c89320376.posop1)
		else
			c89320376.poscost(e,tp,eg,ep,ev,re,r,rp,1)
			c89320376.postg2(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetOperation(c89320376.posop2)
		end
	else
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 效果①的目标选择与确认函数
function c89320376.postg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFacedown() end
	-- 检查自己场上是否存在可以作为对象的里侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只里侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabel(0)
	-- 设置连锁信息，表示该效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的执行函数
function c89320376.posop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		local pos1=0
		if not tc:IsPosition(POS_FACEUP_ATTACK) then pos1=pos1+POS_FACEUP_ATTACK end
		if not tc:IsPosition(POS_FACEUP_DEFENSE) then pos1=pos1+POS_FACEUP_DEFENSE end
		-- 让玩家选择将对象怪兽变成表侧攻击表示或表侧守备表示
		local pos2=Duel.SelectPosition(tp,tc,pos1)
		-- 改变对象怪兽的表示形式
		Duel.ChangePosition(tc,pos2)
	end
end
-- 过滤自己墓地可以回到卡组的「机怪虫」怪兽
function c89320376.cfilter(c)
	return c:IsSetCard(0x104) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动代价（Cost）检查与执行函数
function c89320376.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c89320376.cost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 检查自己墓地是否存在可以回到卡组的「机怪虫」怪兽
		and Duel.IsExistingMatchingCard(c89320376.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「机怪虫」怪兽
	local g=Duel.SelectMatchingCard(tp,c89320376.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 给选中的卡片显示被选择的动画效果
	Duel.HintSelection(g)
	-- 将选中的「机怪虫」怪兽洗回卡组作为发动代价
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	c89320376.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤场上可以变成里侧守备表示的表侧表示怪兽
function c89320376.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的目标选择与确认函数
function c89320376.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c89320376.posfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c89320376.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89320376.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabel(1)
	-- 设置连锁信息，表示该效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的执行函数
function c89320376.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
