--植物連鎖
-- 效果：
-- 发动后这张卡变成攻击力上升500的装备卡，给自己场上存在的1只植物族怪兽装备。变成装备卡的这张卡被其他卡的效果破坏的场合，可以选择自己墓地存在的1只植物族怪兽特殊召唤。
function c54451023.initial_effect(c)
	-- 发动后这张卡变成攻击力上升500的装备卡，给自己场上存在的1只植物族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果发动条件为不在伤害计算后（限制在伤害步骤的伤害计算前发动）
	e1:SetCondition(aux.dscon)
	e1:SetCost(c54451023.cost)
	e1:SetTarget(c54451023.target)
	e1:SetOperation(c54451023.operation)
	c:RegisterEffect(e1)
	-- 变成装备卡的这张卡被其他卡的效果破坏的场合，可以选择自己墓地存在的1只植物族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54451023,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c54451023.spcon)
	e2:SetTarget(c54451023.sptg)
	e2:SetOperation(c54451023.spop)
	c:RegisterEffect(e2)
end
-- 定义发动代价函数，用于处理陷阱卡发动后留在场上以及被无效时的送墓处理
function c54451023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成...装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成攻击力上升500的装备卡，给自己场上存在的1只植物族怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c54451023.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 在全局注册该连锁无效时的处理效果
	Duel.RegisterEffect(e2,tp)
end
-- 定义连锁无效时的处理函数，若此卡发动被无效，则不送去墓地
function c54451023.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发事件的连锁唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤场上表侧表示的植物族怪兽
function c54451023.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 定义发动时的效果目标选择函数（选择自己场上1只植物族怪兽为对象）
function c54451023.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c54451023.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示植物族怪兽
		and Duel.IsExistingTarget(c54451023.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择自己场上1只表侧表示的植物族怪兽作为装备对象
	Duel.SelectTarget(tp,c54451023.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数（将此卡装备给目标怪兽，并使其攻击力上升500）
function c54451023.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取在发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c54451023.filter(tc) then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 给自己场上存在的1只植物族怪兽装备
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c54451023.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 定义装备限制函数，规定此卡只能装备给自身场上的植物族怪兽
function c54451023.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_PLANT)
end
-- 定义特殊召唤效果的发动条件（变成装备卡的此卡被其他卡的效果破坏）
function c54451023.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),REASON_EFFECT+REASON_DESTROY)==REASON_EFFECT+REASON_DESTROY
		and e:GetHandler():GetEquipTarget()
end
-- 过滤墓地中可以特殊召唤的植物族怪兽
function c54451023.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤效果的目标选择函数（选择自己墓地1只植物族怪兽为对象）
function c54451023.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c54451023.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的植物族怪兽
		and Duel.IsExistingTarget(c54451023.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只植物族怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c54451023.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义特殊召唤效果的处理函数（将选择的墓地怪兽特殊召唤）
function c54451023.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的特殊召唤目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
