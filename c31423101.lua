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
	-- 这张卡在自己的主要阶段存在于自己的墓地时，可以把自己墓地的2只战士族从游戏中除外，这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c31423101.equiplimit)
	c:RegisterEffect(e3)
	-- 战士族才能装备。
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
-- 检查装备对象是否为战士族
function c31423101.equiplimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤出正面表示的战士族怪兽
function c31423101.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 设置装备效果的目标选择
function c31423101.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31423101.filter(chkc) end
	-- 判断是否满足装备效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(c31423101.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c31423101.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c31423101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤出可作为除外代价的战士族怪兽
function c31423101.thfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
-- 设置发动加入手牌效果的费用
function c31423101.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足加入手牌效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c31423101.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择除外的怪兽
	local g=Duel.SelectMatchingCard(tp,c31423101.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置发动加入手牌效果的目标
function c31423101.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手牌效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行加入手牌效果
function c31423101.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认此卡加入手牌
		Duel.ConfirmCards(1-tp,c)
	end
end
