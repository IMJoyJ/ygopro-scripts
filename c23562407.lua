--聖剣カリバーン
-- 效果：
-- 战士族怪兽才能装备。装备怪兽的攻击力上升500。此外，1回合1次，自己可以回复500基本分。场上表侧表示存在的这张卡被破坏送去墓地的场合，可以选择自己场上1只名字带有「圣骑士」的战士族怪兽把这张卡装备。「圣剑 石中剑」的这个效果1回合只能使用1次。此外，「圣剑 石中剑」在自己场上只能有1张表侧表示存在。
function c23562407.initial_effect(c)
	c:SetUniqueOnField(1,0,23562407)
	-- 装备怪兽的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c23562407.target)
	e1:SetOperation(c23562407.operation)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，自己可以回复500基本分
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡被破坏送去墓地的场合，可以选择自己场上1只名字带有「圣骑士」的战士族怪兽把这张卡装备
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c23562407.eqlimit)
	c:RegisterEffect(e3)
	-- 「圣剑 石中剑」的这个效果1回合只能使用1次
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23562407,0))  --"回复LP"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c23562407.lptg)
	e4:SetOperation(c23562407.lpop)
	c:RegisterEffect(e4)
	-- 此外，「圣剑 石中剑」在自己场上只能有1张表侧表示存在
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(23562407,1))  --"装备"
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,23562407)
	e5:SetCondition(c23562407.eqcon)
	e5:SetTarget(c23562407.eqtg)
	e5:SetOperation(c23562407.operation2)
	c:RegisterEffect(e5)
end
-- 装备怪兽必须是战士族
function c23562407.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 筛选场上正面表示的战士族怪兽作为装备对象
function c23562407.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 设置装备效果的处理目标为场上正面表示的战士族怪兽
function c23562407.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c23562407.eqfilter1(chkc) end
	-- 判断是否满足装备目标条件
	if chk==0 then return Duel.IsExistingTarget(c23562407.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c23562407.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c23562407.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 设置回复LP效果的目标玩家和回复值
function c23562407.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复LP效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置回复LP效果的回复值为500
	Duel.SetTargetParam(500)
	-- 设置回复LP效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 执行回复LP效果
function c23562407.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和回复值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 判断装备卡是否因破坏而进入墓地且满足唯一性条件
function c23562407.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 筛选场上正面表示的圣骑士战士族怪兽作为装备对象
function c23562407.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- 设置装备效果的处理目标为场上正面表示的圣骑士战士族怪兽
function c23562407.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23562407.eqfilter2(chkc) end
	-- 判断装备卡是否在场且场上存在可用装备区
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备目标条件
		and Duel.IsExistingTarget(c23562407.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的圣骑士战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c23562407.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置装备卡离开墓地的处理信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c23562407.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c23562407.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
