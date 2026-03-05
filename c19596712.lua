--アビスケイル－ケートス
-- 效果：
-- 名字带有「水精鳞」的怪兽才能装备。装备怪兽的攻击力上升800。只要这张卡在场上存在，对方场上发动的陷阱卡的效果无效。那之后，这张卡送去墓地。
function c19596712.initial_effect(c)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19596712.target)
	e1:SetOperation(c19596712.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c19596712.eqlimit)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在，对方场上发动的陷阱卡的效果无效。那之后，这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c19596712.negcon)
	e4:SetOperation(c19596712.negop)
	c:RegisterEffect(e4)
end
-- 装备对象必须是名字带有「水精鳞」的怪兽。
function c19596712.eqlimit(e,c)
	return c:IsSetCard(0x74)
end
-- 检索满足条件的「水精鳞」怪兽。
function c19596712.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74)
end
-- 设置装备效果的处理目标为场上名字带有「水精鳞」的怪兽。
function c19596712.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19596712.filter(chkc) end
	-- 判断是否存在满足条件的装备目标。
	if chk==0 then return Duel.IsExistingTarget(c19596712.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上名字带有「水精鳞」的怪兽作为装备对象。
	Duel.SelectTarget(tp,c19596712.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作。
function c19596712.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否为对方发动的陷阱卡且在场上发动。
function c19596712.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方在场上发动的陷阱卡。
	return rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_SZONE
		-- 判断该陷阱卡的效果可以被无效。
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 处理对方陷阱卡效果无效并送入墓地。
function c19596712.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方陷阱卡的效果无效。
	if Duel.NegateEffect(ev,true) then
		-- 将自身送入墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
