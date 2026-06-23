--ストイック・チャレンジ
-- 效果：
-- 持有超量素材的超量怪兽才能装备。装备怪兽的攻击力上升自己场上的超量素材数量×600的数值，和对方怪兽的战斗给与对方基本分的战斗伤害变成2倍。此外，装备怪兽不能把效果发动。这张卡在对方的结束阶段时送去墓地。这张卡从场上离开时，装备怪兽破坏。「克己挑战」在自己场上只能有1张表侧表示存在。
function c37364101.initial_effect(c)
	c:SetUniqueOnField(1,0,37364101)
	-- 装备怪兽的攻击力上升自己场上的超量素材数量×600的数值，和对方怪兽的战斗给与对方基本分的战斗伤害变成2倍。此外，装备怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37364101.target)
	e1:SetOperation(c37364101.operation)
	c:RegisterEffect(e1)
	-- 持有超量素材的超量怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c37364101.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升自己场上的超量素材数量×600的数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c37364101.atkval)
	c:RegisterEffect(e3)
	-- 对方怪兽的战斗给与对方基本分的战斗伤害变成2倍
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(c37364101.damcon)
	-- 设置战斗伤害为对方受到的伤害翻倍
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
	-- 装备怪兽不能把效果发动
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e5)
	-- 这张卡在对方的结束阶段时送去墓地
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(37364101,0))  --"送去墓地"
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c37364101.tgcon)
	e6:SetTarget(c37364101.tgtg)
	e6:SetOperation(c37364101.tgop)
	c:RegisterEffect(e6)
	-- 这张卡从场上离开时，装备怪兽破坏
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetOperation(c37364101.desop)
	c:RegisterEffect(e7)
end
-- 装备对象必须持有超量素材
function c37364101.eqlimit(e,c)
	return c:GetOverlayCount()>0
end
-- 筛选场上正面表示且有超量素材的怪兽
function c37364101.filter(c)
	return c:IsFaceup() and c:GetOverlayCount()>0
end
-- 选择装备目标怪兽
function c37364101.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37364101.filter(chkc) end
	-- 判断是否存在符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c37364101.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c37364101.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c37364101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力提升值
function c37364101.atkval(e,c)
	-- 返回装备怪兽攻击力提升值
	return Duel.GetOverlayCount(e:GetHandlerPlayer(),1,0)*600
end
-- 判断是否处于战斗阶段
function c37364101.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
-- 判断是否为对方回合
function c37364101.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果拥有者
	return Duel.GetTurnPlayer()~=tp
end
-- 设置送去墓地效果的处理信息
function c37364101.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置送去墓地效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 执行送去墓地操作
function c37364101.tgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将装备卡送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
-- 执行装备怪兽破坏操作
function c37364101.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
