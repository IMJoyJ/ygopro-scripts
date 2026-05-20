--疫病
-- 效果：
-- 战士族·兽战士族·魔法师族怪兽才能装备。装备怪兽的攻击力变成0。此外，每次自己的准备阶段，给与装备怪兽的控制者500分伤害。
function c62472614.initial_effect(c)
	-- 战士族·兽战士族·魔法师族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c62472614.target)
	e1:SetOperation(c62472614.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(0)
	c:RegisterEffect(e2)
	-- 战士族·兽战士族·魔法师族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c62472614.eqlimit)
	c:RegisterEffect(e3)
	-- 此外，每次自己的准备阶段，给与装备怪兽的控制者500分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62472614,0))  --"伤害"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c62472614.damcon)
	e4:SetTarget(c62472614.damtg)
	e4:SetOperation(c62472614.damop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备于战士族、兽战士族或魔法师族怪兽
function c62472614.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR+RACE_BEASTWARRIOR+RACE_SPELLCASTER)
end
-- 过滤条件：场上表侧表示的战士族、兽战士族或魔法师族怪兽
function c62472614.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_BEASTWARRIOR+RACE_SPELLCASTER)
end
-- 效果发动的目标选择与处理信息设置
function c62472614.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c62472614.filter(chkc) end
	-- 检查场上是否存在可以装备的合法目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c62472614.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c62472614.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：此效果包含装备操作，对象为这张卡本身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选定的目标怪兽
function c62472614.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选定的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害效果的发动条件：当前回合玩家是自己的回合
function c62472614.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的目标玩家与参数设置
function c62472614.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local damp=e:GetHandler():GetEquipTarget():GetControler()
	-- 将受到伤害的目标玩家设定为装备怪兽的控制者
	Duel.SetTargetPlayer(damp)
	-- 将伤害数值参数设定为500
	Duel.SetTargetParam(500)
	-- 设置连锁信息：此效果包含给与玩家500点伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,damp,500)
end
-- 伤害效果的处理：给与装备怪兽控制者500点伤害
function c62472614.damop(e,tp,eg,ep,ev,re,r,rp)
	local damp=e:GetHandler():GetEquipTarget():GetControler()
	-- 获取当前连锁中设定的伤害数值参数
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家相应的伤害
	Duel.Damage(damp,d,REASON_EFFECT)
end
