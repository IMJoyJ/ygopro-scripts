--蝕みの鱗粉
-- 效果：
-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击。
-- ②：只要这张卡装备中，每次对方把怪兽召唤·特殊召唤或者每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100。
function c13235258.initial_effect(c)
	-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c13235258.cost)
	e1:SetTarget(c13235258.target)
	e1:SetOperation(c13235258.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡装备中，每次对方把怪兽召唤·特殊召唤或者每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100。
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
	-- 记录连锁发生时这张卡在场上存在
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	-- 注册连锁记录效果
	e5:SetOperation(aux.chainreg)
	c:RegisterEffect(e5)
	-- 当连锁处理结束时，若此卡装备中且对方发动效果，则给对方场上所有表侧表示怪兽放置1个鳞粉指示物
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c13235258.ctcon2)
	e6:SetOperation(c13235258.ctop)
	c:RegisterEffect(e6)
	-- 只要此卡装备中，对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100
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
-- 设置发动时的费用处理
function c13235258.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在发动时不会被无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁被无效时的处理效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c13235258.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e2,tp)
end
-- 处理连锁被无效时的逻辑
function c13235258.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤满足条件的昆虫族怪兽
function c13235258.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 设置发动时的选择目标处理
function c13235258.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13235258.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c13235258.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备目标
	Duel.SelectTarget(tp,c13235258.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置发动效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置发动效果的处理函数
function c13235258.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置此卡只能装备给特定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c13235258.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置对方不能攻击未装备此卡的昆虫族怪兽
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
-- 设置装备限制条件
function c13235258.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_INSECT)
end
-- 设置攻击限制条件
function c13235258.atkcon1(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetControler()==e:GetHandlerPlayer()
end
-- 设置攻击目标
function c13235258.atktg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 过滤召唤玩家为对方的怪兽
function c13235258.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 设置召唤成功时的连锁条件
function c13235258.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and eg:IsExists(c13235258.cfilter,1,nil,1-tp)
end
-- 设置连锁处理时的处理函数
function c13235258.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示显示此卡发动动画
	Duel.Hint(HINT_CARD,0,13235258)
	-- 获取对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1045,1)
		tc=g:GetNext()
	end
end
-- 设置连锁处理结束时的连锁条件
function c13235258.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and ep~=tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 设置攻击力变化的条件
function c13235258.atkcon2(e)
	return e:GetHandler():GetEquipTarget()
end
-- 设置攻击力变化的数值
function c13235258.atkval(e,c)
	return c:GetCounter(0x1045)*-100
end
