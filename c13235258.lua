--蝕みの鱗粉
-- 效果：
-- ①：以自己场上1只昆虫族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。对方不能向那只自己的装备怪兽以外的昆虫族怪兽攻击。
-- ②：只要这张卡装备中，每次对方把怪兽召唤·特殊召唤或者每次对方把魔法·陷阱·怪兽的效果发动，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。对方场上的怪兽的攻击力·守备力下降那怪兽的鳞粉指示物数量×100。
function c13235258.initial_effect(c)
	-- 注册卡片发动（永续陷阱发动）效果：以自己场上1只昆虫族怪兽为对象发动，发动后当作装备卡装备给那只怪兽；并赋予攻击限制（对方不能攻击以外的昆虫族怪兽）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c13235258.cost)
	e1:SetTarget(c13235258.target)
	e1:SetOperation(c13235258.activate)
	c:RegisterEffect(e1)
	-- 注册效果②（召唤部分）：只要这张卡装备中，对方每次召唤怪兽时发动的效果，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
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
	-- 注册连锁注册效果：当有效果发动时，通过 aux.chainreg 标记连锁状态，用于配合效果发动的指示物放置。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	-- 设置连锁注册函数 aux.chainreg，在效果发动连锁时为卡片添加连锁标记。
	e5:SetOperation(aux.chainreg)
	c:RegisterEffect(e5)
	-- 注册效果②（效果发动部分）：只要这张卡装备中，对方每次发动魔法·陷阱·怪兽效果在连锁处理完毕后，给对方场上的表侧表示怪兽全部各放置1个鳞粉指示物。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c13235258.ctcon2)
	e6:SetOperation(c13235258.ctop)
	c:RegisterEffect(e6)
	-- 注册效果②（攻击力·守备力下降部分）：只要这张卡装备中，对方场上怪兽的攻击力·守备力下降该怪兽上的鳞粉指示物数量×100。
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
-- 效果发动的代价函数，为卡片添加留在场上的效果，并注册连锁无效时取消留在场上的处理。
function c13235258.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID，用于关联后续连锁无效时的监控效果。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 注册使陷阱卡在发动处理时留在场上（当作装备卡使用）的单体效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁无效时的监听效果：当此卡发动的连锁被无效时，取消卡片留在场上的状态并送入墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c13235258.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册监听连锁无效的场上效果。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效处理函数，当匹配到对应连锁ID且卡片被无效时，取消留在场上状态并送去墓地。
function c13235258.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的连锁ID并与保存的ID做校验。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 装备目标过滤函数，判断卡片是否为表侧表示的昆虫族怪兽。
function c13235258.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 效果发动的目标选择函数，检查并选择自己场上1只表侧表示昆虫族怪兽作为装备对象。
function c13235258.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13235258.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示昆虫族怪兽。
		and Duel.IsExistingTarget(c13235258.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择装备目标的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示昆虫族怪兽作为装备对象。
	Duel.SelectTarget(tp,c13235258.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为装备分类，目标为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果发动的操作执行函数，将这张卡装备给目标怪兽，并注册装备限制与攻击对象限制效果。
function c13235258.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 注册装备限制效果：这张卡只能装备给该怪兽，或自己场上的昆虫族怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c13235258.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 注册效果①的攻击限制效果：对方不能选择装备怪兽以外的己方昆虫族怪兽作为攻击对象。
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
-- 装备限制函数，判断装备对象是否为当前装备怪兽或己方场上的昆虫族怪兽。
function c13235258.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_INSECT)
end
-- 攻击限制适用条件函数，检查这张卡是否有装备目标且装备目标由自己控制。
function c13235258.atkcon1(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetControler()==e:GetHandlerPlayer()
end
-- 无法被选择攻击的目标判定函数，阻挡对方攻击装备怪兽以外的表侧表示昆虫族怪兽。
function c13235258.atktg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 召唤/特殊召唤过滤函数，检查怪兽是否由指定玩家（对方）召唤或特殊召唤。
function c13235258.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 效果②（召唤/特召）的发动条件函数，检查卡片是否有装备怪兽且对方召唤/特殊召唤了怪兽。
function c13235258.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and eg:IsExists(c13235258.cfilter,1,nil,1-tp)
end
-- 效果②的操作执行函数，给对方场上所有表侧表示怪兽各放置1个鳞粉指示物。
function c13235258.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示信息。
	Duel.Hint(HINT_CARD,0,13235258)
	-- 获取对方场上所有的表侧表示怪兽集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1045,1)
		tc=g:GetNext()
	end
end
-- 效果②（效果发动）的发动条件函数，检查卡片是否有装备怪兽、效果由对方发动且连锁标记有效。
function c13235258.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and ep~=tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 攻击力·守备力下降效果的适用条件函数，检查这张卡是否存在装备怪兽。
function c13235258.atkcon2(e)
	return e:GetHandler():GetEquipTarget()
end
-- 攻击力·守备力下降数值计算函数，计算并返回怪兽持有的鳞粉指示物数量×(-100)。
function c13235258.atkval(e,c)
	return c:GetCounter(0x1045)*-100
end
