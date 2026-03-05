--ガガガシールド
-- 效果：
-- ①：以自己场上1只魔法师族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。装备怪兽1回合最多2次不会被战斗·效果破坏。
function c18446701.initial_effect(c)
	-- 以自己场上1只魔法师族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c18446701.cost)
	e1:SetTarget(c18446701.target)
	e1:SetOperation(c18446701.operation)
	c:RegisterEffect(e1)
end
-- 设置效果为发动时的费用处理函数。
function c18446701.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后不会被送入墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 设置连锁被无效时的处理函数。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c18446701.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时的处理函数注册给全局环境。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，若连锁ID匹配则取消送入墓地。
function c18446701.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选场上正面表示的魔法师族怪兽。
function c18446701.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 设置效果的目标选择函数。
function c18446701.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18446701.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断场上是否存在满足条件的怪兽作为目标。
		and Duel.IsExistingTarget(c18446701.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的魔法师族怪兽作为装备对象。
	Duel.SelectTarget(tp,c18446701.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置效果的处理函数。
function c18446701.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_SPELLCASTER) then
		-- 将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 装备怪兽1回合最多2次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(2)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置此卡只能装备给魔法师族怪兽。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c18446701.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备对象限制函数，确保只能装备给魔法师族怪兽或自身
function c18446701.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_SPELLCASTER)
end
