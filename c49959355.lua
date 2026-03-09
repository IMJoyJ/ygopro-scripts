--ユニゾンビ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。丢弃1张手卡，作为对象的怪兽的等级上升1星。
-- ②：以场上1只表侧表示怪兽为对象才能发动。从卡组把1只不死族怪兽送去墓地，作为对象的怪兽的等级上升1星。这个效果的发动后，直到回合结束时不死族以外的自己怪兽不能攻击。
function c49959355.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。丢弃1张手卡，作为对象的怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49959355,0))  --"丢弃手卡"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,49959355)
	e1:SetCost(c49959355.lvcost)
	e1:SetTarget(c49959355.lvtg1)
	e1:SetOperation(c49959355.lvop1)
	c:RegisterEffect(e1)
	-- ②：以场上1只表侧表示怪兽为对象才能发动。从卡组把1只不死族怪兽送去墓地，作为对象的怪兽的等级上升1星。这个效果的发动后，直到回合结束时不死族以外的自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49959355,1))  --"从卡组把怪兽送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,49959356)
	e2:SetCost(c49959355.lvcost)
	e2:SetTarget(c49959355.lvtg2)
	e2:SetOperation(c49959355.lvop2)
	c:RegisterEffect(e2)
end
-- 支付效果代价，向对方提示本卡效果被发动
function c49959355.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方本卡效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且等级大于0
function c49959355.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 设置效果①的发动条件：手牌数量大于0且场上存在满足条件的怪兽作为对象
function c49959355.lvtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49959355.filter(chkc) end
	-- 检查手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查场上是否存在满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c49959355.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c49959355.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明将要丢弃一张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 处理效果①的发动：丢弃一张手牌并提升目标怪兽等级
function c49959355.lvop1(e,tp,eg,ep,ev,re,r,rp)
	-- 执行丢弃手牌的操作，若失败则返回
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个使目标怪兽等级上升1星的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于筛选可以送去墓地的不死族怪兽
function c49959355.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 设置效果②的发动条件：场上存在满足条件的怪兽作为对象且卡组存在满足条件的不死族怪兽
function c49959355.lvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49959355.filter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c49959355.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查卡组中是否存在满足条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c49959355.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c49959355.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明将要从卡组送去墓地一张怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果②的发动：从卡组选择一只不死族怪兽送去墓地并提升目标怪兽等级，同时设置不能攻击的效果
function c49959355.lvop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家从卡组选择一只怪兽送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一只满足条件的不死族怪兽并将其送去墓地
	local g=Duel.SelectMatchingCard(tp,c49959355.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的怪兽成功送去墓地后执行后续操作
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		-- 获取当前连锁的效果对象
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 创建一个使目标怪兽等级上升1星的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 创建一个使自己场上的非不死族怪兽不能攻击的效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c49959355.atktg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 判断目标是否为非不死族怪兽，用于设置不能攻击效果的适用对象
function c49959355.atktg(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
