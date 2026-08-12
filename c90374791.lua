--アームド・チェンジャー
-- 效果：
-- 从自己手卡把1张装备魔法卡送去墓地发动。装备怪兽战斗破坏怪兽的场合，装备卡的控制者可以从自己墓地选择装备怪兽的攻击力以下的1只怪兽加入手卡。
function c90374791.initial_effect(c)
	-- 从自己手卡把1张装备魔法卡送去墓地发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCost(c90374791.cost)
	e1:SetTarget(c90374791.target)
	e1:SetOperation(c90374791.operation)
	c:RegisterEffect(e1)
	-- 装备魔法卡（设置装备限制）
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏怪兽的场合，装备卡的控制者可以从自己墓地选择装备怪兽的攻击力以下的1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90374791,0))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c90374791.thcon)
	e3:SetTarget(c90374791.thtg)
	e3:SetOperation(c90374791.thop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中可以作为发动代价送去墓地的装备魔法卡
function c90374791.cfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价：从手卡将1张装备魔法卡送去墓地
function c90374791.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可送去墓地的装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90374791.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手卡中1张装备魔法卡送去墓地
	Duel.DiscardHand(tp,c90374791.cfilter,1,1,REASON_COST)
end
-- 魔法卡发动时的效果处理：选择场上1只表侧表示怪兽为对象
function c90374791.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 魔法卡发动时的效果处理：将这张卡装备给选择的怪兽
function c90374791.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 触发条件：装备怪兽战斗破坏了怪兽
function c90374791.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 过滤自己墓地中攻击力在指定数值以下且能加入手卡的怪兽
function c90374791.filter(c,atk)
	return c:IsType(TYPE_MONSTER) and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
-- 触发效果的对象选择：选择自己墓地1只装备怪兽攻击力以下的怪兽为对象
function c90374791.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local eatk=e:GetHandler():GetEquipTarget():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90374791.filter(chkc,eatk) end
	-- 检查自己墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c90374791.filter,tp,LOCATION_GRAVE,0,1,nil,eatk) end
	-- 提示玩家选择要加入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c90374791.filter,tp,LOCATION_GRAVE,0,1,1,nil,eatk)
	-- 设置效果处理信息为：将选中的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 触发效果的处理：将选择的墓地怪兽加入手卡
function c90374791.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
