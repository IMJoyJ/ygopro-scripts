--Kozmo－レイブレード
-- 效果：
-- 念动力族「星际仙踪」怪兽才能装备。「星际仙踪-光线剑」的②的效果1回合只能使用1次。
-- ①：装备怪兽攻击力·守备力上升500，同1次的战斗阶段中最多2次可以向怪兽攻击，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡从场上送去墓地的场合，支付800基本分才能发动。墓地的这张卡加入手卡。
function c82270047.initial_effect(c)
	-- 念动力族「星际仙踪」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c82270047.target)
	e1:SetOperation(c82270047.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽攻击力·守备力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 同1次的战斗阶段中最多2次可以向怪兽攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e6)
	-- 念动力族「星际仙踪」怪兽才能装备。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_EQUIP_LIMIT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(c82270047.eqlimit)
	c:RegisterEffect(e7)
	-- ②：这张卡从场上送去墓地的场合，支付800基本分才能发动。墓地的这张卡加入手卡。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(82270047,0))  --"墓地的这张卡加入手卡"
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,82270047)
	e8:SetCondition(c82270047.thcon)
	e8:SetCost(c82270047.thcost)
	e8:SetTarget(c82270047.thtg)
	e8:SetOperation(c82270047.thop)
	c:RegisterEffect(e8)
end
-- 装备限制：只能装备给念动力族的「星际仙踪」怪兽
function c82270047.eqlimit(e,c)
	return c:IsSetCard(0xd2) and c:IsRace(RACE_PSYCHO)
end
-- 过滤条件：场上表侧表示的念动力族「星际仙踪」怪兽
function c82270047.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd2) and c:IsRace(RACE_PSYCHO)
end
-- 装备魔法卡发动时的对象选择与效果处理
function c82270047.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c82270047.filter(chkc) end
	-- 检查场上是否存在可装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c82270047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c82270047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为将这张卡作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的装备效果处理
function c82270047.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查装备怪兽是否已进行过攻击宣言
function c82270047.dircon(e)
	return e:GetHandler():GetEquipTarget():GetAttackAnnouncedCount()>0
end
-- 检查这张卡是否是从场上送去墓地
function c82270047.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 支付800基本分的发动代价处理
function c82270047.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800基本分
	Duel.PayLPCost(tp,800)
end
-- 回收效果的发动准备与合法性检查
function c82270047.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回收效果的实际处理
function c82270047.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
