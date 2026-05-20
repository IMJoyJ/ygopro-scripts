--呪魂の仮面
-- 效果：
-- 这张卡装备的怪兽不能攻击。装备怪兽的控制者在自己的每次的准备阶段受到500分的伤害。
function c56948373.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c56948373.target)
	e1:SetOperation(c56948373.operation)
	c:RegisterEffect(e1)
	-- 这张卡装备的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 装备怪兽的控制者在自己的每次的准备阶段受到500分的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56948373,0))  --"伤害"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c56948373.damcon)
	e4:SetTarget(c56948373.damtg)
	e4:SetOperation(c56948373.damop)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的对象选择过滤与效果注册
function c56948373.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示该效果的处理是装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理，将自身装备给目标怪兽
function c56948373.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害效果的发动条件判断
function c56948373.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是当前回合玩家的准备阶段，且这张卡已装备在怪兽上
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetEquipTarget()~=nil
end
-- 伤害效果的发动准备，确定受伤害的玩家和伤害数值
function c56948373.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 设置受到伤害的目标玩家
	Duel.SetTargetPlayer(p)
	-- 设置伤害数值为500
	Duel.SetTargetParam(500)
	-- 设置操作信息，表示该效果的处理是给与目标玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
-- 伤害效果的具体执行
function c56948373.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要受到伤害的玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
