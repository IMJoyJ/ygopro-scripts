--コアバスター
-- 效果：
-- 名字带有「核成」的怪兽才能装备。装备怪兽和光属性或者暗属性怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。装备怪兽从场上离开让这张卡被送去墓地时，这张卡可以回到手卡。
function c59385322.initial_effect(c)
	-- 名字带有「核成」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c59385322.target)
	e1:SetOperation(c59385322.operation)
	c:RegisterEffect(e1)
	-- 名字带有「核成」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c59385322.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽和光属性或者暗属性怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59385322,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(c59385322.descon)
	e3:SetTarget(c59385322.destg)
	e3:SetOperation(c59385322.desop)
	c:RegisterEffect(e3)
	-- 装备怪兽从场上离开让这张卡被送去墓地时，这张卡可以回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59385322,1))  --"返回手牌"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c59385322.thcon)
	e4:SetTarget(c59385322.thtg)
	e4:SetOperation(c59385322.thop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给「核成」怪兽
function c59385322.eqlimit(e,c)
	return c:IsSetCard(0x1d)
end
-- 过滤条件：场上表侧表示的「核成」怪兽
function c59385322.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 装备魔法卡发动时的效果目标选择与处理
function c59385322.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c59385322.filter(chkc) end
	-- 检查场上是否存在可以装备的「核成」怪兽
	if chk==0 then return Duel.IsExistingTarget(c59385322.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的「核成」怪兽作为装备对象
	Duel.SelectTarget(tp,c59385322.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的装备处理
function c59385322.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 破坏效果的发动条件：装备怪兽与光属性或暗属性怪兽进行战斗
function c59385322.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽是否是本次战斗的攻击怪兽或被攻击怪兽
	if ec~=Duel.GetAttacker() and ec~=Duel.GetAttackTarget() then return false end
	local tc=ec:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 破坏效果的目标设置
function c59385322.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为破坏进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 破坏效果的执行：破坏与装备怪兽战斗的怪兽
function c59385322.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 破坏进行战斗的对方怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 回手卡效果的发动条件：装备怪兽从场上离开导致这张卡被送去墓地
function c59385322.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_LOST_TARGET)
		and not e:GetHandler():GetPreviousEquipTarget():IsLocation(LOCATION_ONFIELD+LOCATION_OVERLAY)
end
-- 回手卡效果的目标设置
function c59385322.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回手卡效果的执行：将这张卡加入手卡并给对方确认
function c59385322.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
