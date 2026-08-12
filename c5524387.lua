--海晶乙女マーブルド・ロック
-- 效果：
-- 水属性怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以「海晶少女 石狗公」以外的自己墓地1张「海晶少女」卡为对象才能发动。那张卡加入手卡。
-- ②：对方怪兽的攻击宣言时，从手卡把1只「海晶少女」怪兽送去墓地才能发动。怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
function c5524387.initial_effect(c)
	-- 添加连接召唤手续：水属性怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2)
	c:EnableReviveLimit()
	-- ①：以「海晶少女 石狗公」以外的自己墓地1张「海晶少女」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5524387,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5524387)
	e1:SetTarget(c5524387.thtg)
	e1:SetOperation(c5524387.thop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，从手卡把1只「海晶少女」怪兽送去墓地才能发动。怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5524387,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c5524387.condition)
	e2:SetCost(c5524387.cost)
	e2:SetOperation(c5524387.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地「海晶少女 石狗公」以外的「海晶少女」卡，且能加入手卡
function c5524387.thfilter(c)
	return c:IsSetCard(0x12b) and not c:IsCode(5524387) and c:IsAbleToHand()
end
-- 效果①（回收墓地卡片）的发动准备与目标选择
function c5524387.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c5524387.thfilter(chkc) end
	-- 检查自己墓地是否存在满足回收条件的卡
	if chk==0 then return Duel.IsExistingTarget(c5524387.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c5524387.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①（回收墓地卡片）的效果处理
function c5524387.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②（战斗保护）的发动条件判定
function c5524387.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击宣言的怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：手牌中的「海晶少女」怪兽，且能作为代价送去墓地
function c5524387.cfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果②（战斗保护）的发动代价处理
function c5524387.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价送去墓地的「海晶少女」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5524387.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌将1只「海晶少女」怪兽送去墓地
	Duel.DiscardHand(tp,c5524387.cfilter,1,1,REASON_COST)
end
-- 效果②（战斗保护）的效果处理
function c5524387.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	-- 怪兽不会被那次战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	a:RegisterEffect(e1)
	if d then
		-- 怪兽不会被那次战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e2)
	end
	-- 那次战斗发生的对自己的战斗伤害变成0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使玩家受到的战斗伤害变成0的效果
	Duel.RegisterEffect(e3,tp)
end
