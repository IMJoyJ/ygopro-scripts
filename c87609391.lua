--ラプターズ・アルティメット・メイス
-- 效果：
-- 「急袭猛禽」怪兽才能装备。
-- ①：装备怪兽的攻击力上升1000。
-- ②：装备怪兽被选择作为比装备怪兽攻击力高的怪兽的攻击对象时才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡，那次战斗发生的对自己的战斗伤害变成0。
function c87609391.initial_effect(c)
	-- 「急袭猛禽」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c87609391.target)
	e1:SetOperation(c87609391.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 「急袭猛禽」怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c87609391.eqlimit)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被选择作为比装备怪兽攻击力高的怪兽的攻击对象时才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡，那次战斗发生的对自己的战斗伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCondition(c87609391.thcon)
	e4:SetTarget(c87609391.thtg)
	e4:SetOperation(c87609391.thop)
	c:RegisterEffect(e4)
end
-- 限制这张卡只能装备给「急袭猛禽」怪兽
function c87609391.eqlimit(e,c)
	return c:IsSetCard(0xba)
end
-- 过滤场上表侧表示的「急袭猛禽」怪兽
function c87609391.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xba)
end
-- 装备魔法卡发动时的效果对象选择与操作信息设置
function c87609391.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c87609391.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示「急袭猛禽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c87609391.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的「急袭猛禽」怪兽作为装备对象
	Duel.SelectTarget(tp,c87609391.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的装备处理
function c87609391.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备怪兽是否被比其攻击力高的怪兽选择为攻击对象
function c87609391.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local ec=e:GetHandler():GetEquipTarget()
	-- 获取本次战斗的攻击怪兽
	local at=Duel.GetAttacker()
	return tc==ec and at and at:GetAttack()>ec:GetAttack()
end
-- 过滤卡组中可以加入手牌的「升阶魔法」魔法卡
function c87609391.thfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的发动准备与操作信息设置
function c87609391.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87609391.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 将「升阶魔法」魔法卡加入手牌，并使该次战斗发生的对自己的战斗伤害变成0
function c87609391.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「升阶魔法」魔法卡
	local g=Duel.SelectMatchingCard(tp,c87609391.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		-- 获取进行攻击的怪兽
		local tc=Duel.GetAttacker()
		if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsAttackable() then
			-- 那次战斗发生的对自己的战斗伤害变成0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(1)
			e1:SetCondition(c87609391.damcon)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
			e1:SetLabelObject(tc)
			-- 在全局注册该次战斗伤害变成0的效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断当前进行伤害计算的攻击怪兽是否为发动效果时的攻击怪兽
function c87609391.damcon(e)
	-- 检查当前攻击怪兽是否与之前记录的攻击怪兽一致
	return e:GetLabelObject()==Duel.GetAttacker()
end
