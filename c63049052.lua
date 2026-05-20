--璽律する武神
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上1只4阶的超量怪兽装备。装备怪兽的攻击力上升那只怪兽的超量素材数量×300的数值。此外，这个效果让这张卡装备中的场合，1回合1次，可以把手卡1只名字带有「武神」的怪兽在装备怪兽下面重叠作为超量素材。
function c63049052.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上1只4阶的超量怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果发动的条件为不在伤害计算后（允许在伤害步骤的其他时机发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c63049052.cost)
	e1:SetTarget(c63049052.target)
	e1:SetOperation(c63049052.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的Cost，用于处理陷阱卡发动后留在场上作为装备卡，以及在发动被无效时送去墓地的规则处理。
function c63049052.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成装备卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c63049052.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将用于处理发动被无效时送去墓地的效果注册给玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 发动被无效时的处理：取消该卡留在场上的状态，使其正常送去墓地。
function c63049052.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：自己场上表侧表示的4阶怪兽。
function c63049052.filter(c)
	return c:IsFaceup() and c:IsRank(4)
end
-- 效果发动的靶向选择阶段，确认场上是否存在合法的4阶怪兽并进行取对象选择。
function c63049052.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c63049052.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件的4阶怪兽作为合法的选择对象。
		and Duel.IsExistingTarget(c63049052.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的4阶怪兽作为效果的对象。
	Duel.SelectTarget(tp,c63049052.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息为：将这张卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理阶段，将这张卡装备给目标怪兽，并赋予其攻击力上升和补充超量素材的效果。
function c63049052.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取在发动时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 装备怪兽的攻击力上升那只怪兽的超量素材数量×300的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(c63049052.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 此外，这个效果让这张卡装备中的场合，1回合1次，可以把手卡1只名字带有「武神」的怪兽在装备怪兽下面重叠作为超量素材。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(63049052,0))  --"补充素材"
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1)
		e2:SetTarget(c63049052.mattg)
		e2:SetOperation(c63049052.matop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给自己场上1只4阶的超量怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c63049052.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 计算攻击力上升值：装备怪兽的超量素材数量乘以300。
function c63049052.atkval(e,c)
	return c:GetOverlayCount()*300
end
-- 装备限制条件：只能装备给自己场上的4阶怪兽。
function c63049052.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRank(4)
end
-- 过滤条件：手卡中可以作为超量素材的名字带有「武神」的怪兽。
function c63049052.mfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 补充素材效果的发动准备，确认手卡中是否存在合法的「武神」怪兽。
function c63049052.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以作为超量素材的「武神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c63049052.mfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 补充素材效果的处理：让玩家选择手卡中的「武神」怪兽重叠作为装备怪兽的超量素材。
function c63049052.matop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从手卡选择1只满足条件的「武神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c63049052.mfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽重叠作为装备怪兽的超量素材。
		Duel.Overlay(ec,g)
	end
end
