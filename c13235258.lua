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
	-- ②：只要这张卡装备中，每次对方把怪兽召唤·特殊召唤，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
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
	-- ②：每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	-- 使用aux.chainreg记录此卡在连锁中是否在场上，以便后续判断是否触发效果
	e5:SetOperation(aux.chainreg)
	c:RegisterEffect(e5)
	-- ②：每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c13235258.ctcon2)
	e6:SetOperation(c13235258.ctop)
	c:RegisterEffect(e6)
	-- ②：对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100。
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
-- 此函数处理cost效果，注册EFFECT_REMAIN_FIELD使此卡在连锁结束后保留在场上，并在连锁被无效时将其返回墓地
function c13235258.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于后续判断该连锁是否被无效
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- ①：这张卡当作装备卡使用给那只怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c13235258.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册e2效果，用于在连锁被无效时将卡返回墓地
	Duel.RegisterEffect(e2,tp)
end
-- 此函数在连锁被无效时检测该连锁是否为当前卡发动的连锁，若匹配则将此卡返回墓地
function c13235258.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发EVENT_CHAIN_DISABLED的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤函数：返回场上表侧表示的昆虫族怪兽
function c13235258.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 目标函数：检查是否有符合条件的昆虫族怪兽作为装备对象
function c13235258.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13235258.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在符合条件的装备对象
		and Duel.IsExistingTarget(c13235258.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择装备对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择要装备的昆虫族怪兽
	Duel.SelectTarget(tp,c13235258.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备操作信息，指定CATEGORY_EQUIP
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作并注册装备限制和攻击限制效果
function c13235258.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取玩家选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备到目标怪兽上
		Duel.Equip(tp,c,tc)
		-- ①：这张卡当作装备卡使用给那只怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c13235258.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ①：对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击
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
-- 装备限制函数：判断卡片是否可以成为装备对象（自身或控制的昆虫族怪兽）
function c13235258.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_INSECT)
end
-- 攻击限制条件：此卡装备的怪兽必须在我方场上
function c13235258.atkcon1(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetControler()==e:GetHandlerPlayer()
end
-- 攻击限制目标：返回不能成为攻击对象的昆虫族怪兽
function c13235258.atktg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 过滤函数：判断召唤是否是对方玩家进行的
function c13235258.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 条件函数：此卡已装备且对方进行了召唤或特殊召唤
function c13235258.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and eg:IsExists(c13235258.cfilter,1,nil,1-tp)
end
-- 效果处理：为对方场上的所有表侧表示怪兽各放置1个鳞粉指示物
function c13235258.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示：显示此卡的发动动画
	Duel.Hint(HINT_CARD,0,13235258)
	-- 获取对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1045,1)
		tc=g:GetNext()
	end
end
-- 条件函数：此卡已装备且对方发动了魔法·陷阱·怪兽效果且该连锁已被记录
function c13235258.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and ep~=tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 攻击·守备力下降条件：此卡已装备
function c13235258.atkcon2(e)
	return e:GetHandler():GetEquipTarget()
end
-- 返回攻击力·守备力下降值：鳞粉指示物数量×100
function c13235258.atkval(e,c)
	return c:GetCounter(0x1045)*-100
end
