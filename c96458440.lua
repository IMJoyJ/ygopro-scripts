--伝説の黒帯
-- 效果：
-- 自己场上的「格斗鼠 吱助」「武僧战士」「武僧大师」才能装备。装备怪兽因战斗破坏对方怪兽送去墓地时，给与对方基本分被破坏怪兽守备力数值的伤害。
function c96458440.initial_effect(c)
	-- 注册卡片记有「格斗鼠 吱助」「武僧战士」「武僧大师」的卡名信息
	aux.AddCodeList(c,8508055,3810071,49814180)
	-- 自己场上的「格斗鼠 吱助」「武僧战士」「武僧大师」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c96458440.target)
	e1:SetOperation(c96458440.operation)
	c:RegisterEffect(e1)
	-- 自己场上的「格斗鼠 吱助」「武僧战士」「武僧大师」才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c96458440.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽因战斗破坏对方怪兽送去墓地时，给与对方基本分被破坏怪兽守备力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96458440,0))  --"LP伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(c96458440.damcon)
	e4:SetTarget(c96458440.damtg)
	e4:SetOperation(c96458440.damop)
	c:RegisterEffect(e4)
end
-- 限制装备对象为自己场上的「格斗鼠 吱助」、「武僧战士」或「武僧大师」
function c96458440.eqlimit(e,c)
	return c:IsCode(8508055,3810071,49814180) and c:IsControler(e:GetHandlerPlayer())
end
-- 过滤场上表侧表示的「格斗鼠 吱助」、「武僧战士」或「武僧大师」
function c96458440.filter(c)
	return c:IsFaceup() and c:IsCode(8508055,3810071,49814180)
end
-- 装备魔法卡发动时的效果处理（选择装备对象）
function c96458440.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c96458440.filter(chkc) end
	-- 检查自己场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c96458440.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c96458440.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理（执行装备）
function c96458440.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判定是否为装备怪兽因战斗破坏对方怪兽并送去墓地的时点
function c96458440.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return ec==e:GetHandler():GetEquipTarget() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 伤害效果的发动准备，计算被破坏怪兽的守备力并设置伤害参数
function c96458440.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	local dam=bc:GetDefense()
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为被破坏怪兽的守备力
	Duel.SetTargetParam(dam)
	-- 设置效果处理信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的实际处理
function c96458440.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取预设的伤害目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 实际给与对方玩家效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
