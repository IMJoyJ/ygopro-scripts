--アビスケイル－ミヅチ
-- 效果：
-- 名字带有「水精鳞」的怪兽才能装备。装备怪兽的攻击力上升800。只要这张卡在场上存在，对方场上发动的魔法卡的效果无效。那之后，这张卡送去墓地。
function c72932673.initial_effect(c)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c72932673.target)
	e1:SetOperation(c72932673.operation)
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
	e3:SetValue(c72932673.eqlimit)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在，对方场上发动的魔法卡的效果无效。那之后，这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c72932673.negcon)
	e4:SetOperation(c72932673.negop)
	c:RegisterEffect(e4)
end
-- 定义装备限制，判断怪兽是否为「水精鳞」怪兽
function c72932673.eqlimit(e,c)
	return c:IsSetCard(0x74)
end
-- 过滤场上表侧表示的「水精鳞」怪兽
function c72932673.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74)
end
-- 装备魔法卡发动时的靶向处理，选择装备对象并设置操作信息
function c72932673.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c72932673.filter(chkc) end
	-- 检查场上是否存在可装备的表侧表示「水精鳞」怪兽
	if chk==0 then return Duel.IsExistingTarget(c72932673.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「水精鳞」怪兽作为装备对象
	Duel.SelectTarget(tp,c72932673.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果分类为装备，并指定自身为操作对象
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，执行装备操作
function c72932673.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将自身作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足无效魔法卡效果的条件（对方在魔陷区发动魔法卡的效果）
function c72932673.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and bit.band(loc,LOCATION_SZONE)~=0
		-- 判断连锁的效果是否为魔法卡效果且可以被无效
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end
-- 无效魔法卡效果并送去墓地的效果处理
function c72932673.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果
	if Duel.NegateEffect(ev,true) then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
