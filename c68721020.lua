--Sin Force
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽不受魔法卡的效果影响。
-- ●1回合1次，可以发动。这张卡破坏，从卡组把1张「罪」卡加入手卡。
-- ②：场地区域有卡存在的场合，从自己墓地把这张卡和1张「罪」卡除外才能发动。场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化函数，注册魔法卡的发动效果以及墓地发动的破坏效果
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：场地区域有卡存在的场合，从自己墓地把这张卡和1张「罪」卡除外才能发动。场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 魔法卡发动时的Cost处理函数（注册发动被无效时不送去墓地的效果）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁被无效时将卡片送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的具体处理：取消送去墓地的标志
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 装备怪兽过滤函数：场上表侧表示的怪兽
function s.filter(c)
	return c:IsFaceup()
end
-- 效果①的发动准备与目标选择函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在可以装备的表侧表示怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示请选择要装备的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的操作信息为：装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToChain() or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取选定的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- ●装备怪兽不受魔法卡的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ●1回合1次，可以发动。这张卡破坏，从卡组把1张「罪」卡加入手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))  --"破坏并检索"
		e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_SZONE)
		e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e2:SetCountLimit(1)
		e2:SetTarget(s.thtg)
		e2:SetOperation(s.thop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 不受影响的效果过滤函数：不受魔法卡效果影响
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 检索卡片过滤函数：「罪」卡
function s.thfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToHand()
end
-- 装备卡效果的发动准备与检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在「罪」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前处理的操作信息为：破坏自己
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置当前处理的操作信息为：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 装备卡效果的执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡正常结算并将其破坏
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 显示请选择要加入手牌的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「罪」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「罪」卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件检测函数
function s.descon(e)
	-- 检查场地区域是否有卡存在
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- Cost除外卡片过滤条件：墓地的「罪」卡
function s.cfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToRemoveAsCost()
end
-- 效果②的Cost处理与发动检查函数
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查墓地除了这张卡以外是否存在「罪」卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 显示请选择要除外的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地的1张「罪」卡进行除外
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的「罪」卡和墓地的此卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动检测与效果分类注册函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if chk==0 then return #g>0 end
	-- 设置当前处理的操作信息为：破坏场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②的效果处理执行函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 破坏场上的所有怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
