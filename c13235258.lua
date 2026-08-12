--蝕みの鱗粉
-- 效果：
-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击。
-- ②：只要这张卡装备中，每次对方把怪兽召唤·特殊召唤或者每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100。
function c13235258.initial_effect(c)
	-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c13235258.cost)
	e1:SetTarget(c13235258.target)
	e1:SetOperation(c13235258.activate)
	c:RegisterEffect(e1)
	-- 只要这张卡装备中，每次对方把怪兽召唤·特殊召唤，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c13235258.ctcon1)
	e3:SetOperation(c13235258.ctop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 只要这张卡装备中，每次对方把魔法·陷阱·怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	-- 记录连锁发生时这张卡在场上存在，供后续连锁处理结束时判断是否放置鳞粉指示物。
	e5:SetOperation(aux.chainreg)
	c:RegisterEffect(e5)
	-- 每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c13235258.ctcon2)
	e6:SetOperation(c13235258.ctop)
	c:RegisterEffect(e6)
	-- 对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(0,LOCATION_MZONE)
	e7:SetCondition(c13235258.atkcon2)
	e7:SetValue(c13235258.atkval)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
end
c13235258.mentioned_counter={
	[0x1045]=true,
}
-- 发动的代价处理：赋予这张卡本连锁内留在场上的誓约效果，并注册本连锁被无效时把这张卡送去墓地的检测效果。
function c13235258.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 取得当前正在处理的连锁的唯一标识ID，用于之后识别本连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c13235258.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 把连锁被无效的检测效果注册为玩家的全局效果，使其在本连锁中生效。
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，若被无效的连锁正是这张卡发动的连锁，则把这张卡送去墓地。
function c13235258.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被无效的那次连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤函数：表侧表示的昆虫族怪兽。
function c13235258.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 取对象目标检查：确认代价已支付且自己场上存在能成为对象的表侧表示昆虫族怪兽。
function c13235258.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13235258.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己怪兽区是否存在1只以上能成为对象的表侧表示昆虫族怪兽。
		and Duel.IsExistingTarget(c13235258.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备这张卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的昆虫族怪兽作为效果对象。
	Duel.SelectTarget(tp,c13235258.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为装备分类，预告这张卡将被当作装备卡处理。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：把这张卡当作装备卡使用给对象怪兽装备，并赋予装备限制和不能向其他昆虫族怪兽攻击的效果；对象已不在场或变成里侧时把这张卡送去墓地。
function c13235258.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得当前连锁的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把这张卡当作装备卡使用给对象怪兽装备。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c13235258.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCondition(c13235258.atkcon1)
		e2:SetValue(c13235258.atktg)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：这张卡只能装备给该装备对象或自己场上的昆虫族怪兽。
function c13235258.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_INSECT)
end
-- 条件：这张卡的装备怪兽存在且由自己控制。
function c13235258.atkcon1(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetControler()==e:GetHandlerPlayer()
end
-- 不能选择为攻击对象的卡：装备怪兽以外的表侧表示昆虫族怪兽。
function c13235258.atktg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 过滤函数：把怪兽召唤·特殊召唤的玩家为指定玩家的怪兽。
function c13235258.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 条件：这张卡装备中，且召唤·特殊召唤成功的怪兽中有对方召唤·特殊召唤的怪兽。
function c13235258.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and eg:IsExists(c13235258.cfilter,1,nil,1-tp)
end
-- 给对方场上全部表侧表示怪兽各放置1个鳞粉指示物。
function c13235258.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡的效果处理提示动画（不入连锁的处理提示）。
	Duel.Hint(HINT_CARD,0,13235258)
	-- 取得对方场上全部表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1045,1)
		tc=g:GetNext()
	end
end
-- 条件：这张卡装备中，该连锁由对方发动，且这张卡在连锁发生时已在场上存在。
function c13235258.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and ep~=tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 条件：这张卡装备中（存在装备对象）。
function c13235258.atkcon2(e)
	return e:GetHandler():GetEquipTarget()
end
-- 攻击力·守备力下降的数值：该怪兽的鳞粉指示物数量×100。
function c13235258.atkval(e,c)
	return c:GetCounter(0x1045)*-100
end
