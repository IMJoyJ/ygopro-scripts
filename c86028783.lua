--新鋭の女戦士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的其他的战士族怪兽和对方的表侧表示怪兽进行战斗的攻击宣言时，把手卡·场上的这张卡送去墓地才能发动。那只对方怪兽的攻击力直到回合结束时下降那自身原本攻击力数值。
-- ②：把墓地的这张卡除外，以自己墓地1只战士族·地属性怪兽为对象才能发动。那只怪兽加入手卡。
function c86028783.initial_effect(c)
	-- ①：自己的其他的战士族怪兽和对方的表侧表示怪兽进行战斗的攻击宣言时，把手卡·场上的这张卡送去墓地才能发动。那只对方怪兽的攻击力直到回合结束时下降那自身原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,86028783)
	e1:SetCondition(c86028783.atkcon)
	e1:SetCost(c86028783.atkcost)
	e1:SetOperation(c86028783.atkop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只战士族·地属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86028784)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86028783.thtg)
	e2:SetOperation(c86028783.thop)
	c:RegisterEffect(e2)
end
-- 判断是否是自己的其他战士族怪兽与对方的表侧表示怪兽进行战斗的攻击宣言时
function c86028783.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行战斗的己方和对方的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a~=c and a:IsFaceup() and a:IsRace(RACE_WARRIOR) and d:IsFaceup()
end
-- 把手卡·场上的这张卡送去墓地作为发动代价
function c86028783.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 使进行战斗的对方怪兽的攻击力直到回合结束时下降其原本攻击力的数值
function c86028783.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取进行战斗的对方怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力直到回合结束时下降那自身原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤自己墓地中可以加入手卡的战士族·地属性怪兽
function c86028783.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果②的发动准备：选择自己墓地1只战士族·地属性怪兽作为对象
function c86028783.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c86028783.filter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的战士族·地属性怪兽（排除自身）
	if chk==0 then return Duel.IsExistingTarget(c86028783.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只战士族·地属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86028783.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：将作为对象的怪兽加入手卡
function c86028783.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
