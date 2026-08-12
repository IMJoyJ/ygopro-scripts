--パラレルポート・アーマー
-- 效果：
-- ①：以自己场上1只连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会成为对方的效果的对象，不会被战斗破坏。
-- ②：从自己墓地把这张卡和2只连接怪兽除外，以自己场上1只连接怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c879958.initial_effect(c)
	-- ①：以自己场上1只连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会成为对方的效果的对象，不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c879958.cost)
	e1:SetTarget(c879958.target)
	e1:SetOperation(c879958.operation)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和2只连接怪兽除外，以自己场上1只连接怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(879958,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 设置发动条件为：当前可以进入战斗阶段，或者正处于战斗阶段中
	e2:SetCondition(aux.bpcon)
	e2:SetCost(c879958.atkcost)
	e2:SetTarget(c879958.atktg)
	e2:SetOperation(c879958.atkop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价函数，用于在发动时将卡片留在场上，并处理发动被无效时的送墓逻辑
function c879958.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用给那只怪兽装备
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c879958.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将用于处理发动被无效时送去墓地的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 发动被无效时的处理函数：如果此卡的发动被无效，则取消留在场上的状态，将其送去墓地
function c879958.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：表侧表示的连接怪兽
function c879958.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- ①号效果的对象选择与发动准备函数
function c879958.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c879958.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件的连接怪兽作为对象
		and Duel.IsExistingTarget(c879958.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的连接怪兽作为效果对象
	Duel.SelectTarget(tp,c879958.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制函数：只能装备给属于自己且是连接怪兽的怪兽
function c879958.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_LINK)
end
-- ①号效果的执行函数：将此卡装备给目标怪兽，并赋予抗性
function c879958.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁中选择的第一个对象（即要装备的连接怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备怪兽不会成为对方的效果的对象
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置不能成为对方卡片效果的对象
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 这张卡当作装备卡使用给那只怪兽装备
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c879958.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 过滤条件：墓地中可以作为发动代价除外的连接怪兽
function c879958.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- ②号效果的发动代价函数：将此卡和2只连接怪兽除外
function c879958.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在另外2只可以除外的连接怪兽
		and Duel.IsExistingMatchingCard(c879958.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家发送提示信息：选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2只连接怪兽
	local g=Duel.SelectMatchingCard(tp,c879958.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽以表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己场上表侧表示、且未获得追加攻击效果的连接怪兽
function c879958.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- ②号效果的对象选择与准备函数
function c879958.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c879958.atkfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c879958.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的连接怪兽作为效果对象
	Duel.SelectTarget(tp,c879958.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的执行函数：赋予目标怪兽在同一次战斗阶段中作2次攻击的能力
function c879958.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
