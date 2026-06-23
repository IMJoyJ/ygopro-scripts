--ラッシュ・ウォリアー
-- 效果：
-- 「突进战士」的①②的效果1回合各能使用1次。
-- ①：自己的「战士」同调怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时变成2倍。
-- ②：把墓地的这张卡除外，以自己墓地1只「同调士」怪兽为对象才能发动。那只怪兽加入手卡。
function c36736723.initial_effect(c)
	-- ①：自己的「战士」同调怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36736723,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36736723)
	e1:SetCondition(c36736723.atkcon)
	e1:SetCost(c36736723.atkcost)
	e1:SetOperation(c36736723.atkop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「同调士」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36736723,1))  --"卡片回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,36736724)
	-- 效果发动时把这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36736723.thtg)
	e2:SetOperation(c36736723.thop)
	c:RegisterEffect(e2)
end
-- 效果发动时判断是否满足发动条件：攻击怪兽是否为战士族同调怪兽
function c36736723.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中攻击方的防守怪兽
	local tc=Duel.GetAttackTarget()
	if not tc then return false end
	-- 如果防守怪兽是对方控制，则获取攻击方怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttacker() end
	e:SetLabelObject(tc)
	return tc and tc:IsRelateToBattle() and tc:IsSetCard(0x66) and tc:IsType(TYPE_SYNCHRO)
end
-- 效果发动时的费用处理：将自身送去墓地
function c36736723.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动时执行的操作：将攻击怪兽攻击力变为2倍
function c36736723.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 将攻击怪兽的攻击力变为2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
	end
end
-- 筛选墓地中的「同调士」怪兽的过滤条件
function c36736723.filter(c)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的处理：选择目标怪兽
function c36736723.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36736723.filter(chkc) end
	-- 判断是否满足发动条件：自己墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36736723.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c36736723.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时执行的操作：将目标怪兽加入手牌
function c36736723.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
