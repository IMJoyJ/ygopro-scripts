--神剣－フェニックスブレード
-- 效果：
-- 战士族才能装备。装备怪兽的攻击力上升300。这张卡在自己的主要阶段存在于自己的墓地时，可以把自己墓地的2只战士族从游戏中除外，这张卡加入手卡。
function c31423101.initial_effect(c)
	-- 战士族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c31423101.target)
	e1:SetOperation(c31423101.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 战士族才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c31423101.equiplimit)
	c:RegisterEffect(e3)
	-- 这张卡在自己的主要阶段存在于自己的墓地时，可以把自己墓地的2只战士族从游戏中除外，这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(31423101,0))  --"这张卡加入手牌"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c31423101.thcost)
	e4:SetTarget(c31423101.thtg)
	e4:SetOperation(c31423101.thop)
	c:RegisterEffect(e4)
end
-- 判定装备对象是否为战士族怪兽，用于实现“战士族才能装备”的限制。
function c31423101.equiplimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤出场上表侧表示且种族为战士族的怪兽，作为此装备卡可以装备的对象。
function c31423101.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法发动时的取对象处理：选择场上1只表侧表示战士族怪兽作为装备对象，并设置操作信息。
function c31423101.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31423101.filter(chkc) end
	-- 发动前检查场上是否存在1只以上表侧表示战士族怪兽可以作为装备对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c31423101.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方主要怪兽区选择1只表侧表示战士族怪兽作为装备对象（取对象）。
	Duel.SelectTarget(tp,c31423101.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为装备效果，操作对象为这张卡自身，数量为1，用于效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动后的处理：若这张卡和目标怪兽仍与效果关联且目标怪兽为表侧表示，则将此卡装备给目标怪兽。
function c31423101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象卡。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给选择的目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 墓地效果发动代价的过滤条件：必须是战士族怪兽且可以作为代价除外。
function c31423101.thfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
-- 墓地效果发动时的代价处理：从自己墓地选择2只战士族怪兽除外。
function c31423101.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己墓地是否存在2只以上符合条件的战士族怪兽可以作为代价，若不足则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31423101.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向操作者显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2只战士族怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c31423101.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2只战士族怪兽以表侧表示从游戏中除外，作为代价处理。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 墓地效果的目标处理：确认此卡可以加入手卡，并设置返回手牌的操作信息。
function c31423101.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置本次连锁的处理为加入手牌效果，处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地效果的处理：若此卡仍与效果关联，则将其加入手牌，并让对方确认。
function c31423101.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地加入其持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
