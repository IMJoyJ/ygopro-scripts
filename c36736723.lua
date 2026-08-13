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
	-- 设置②效果的发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36736723.thtg)
	e2:SetOperation(c36736723.thop)
	c:RegisterEffect(e2)
end
-- 判断①效果的发动条件：自己的「战士」同调怪兽和对方怪兽进行战斗的伤害计算时，且该怪兽仍与战斗相关。
function c36736723.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前战斗的攻击对象（被攻击的怪兽）。
	local tc=Duel.GetAttackTarget()
	if not tc then return false end
	-- 若攻击对象是对方怪兽，则将参考对象改为攻击怪兽，确保取到的是己方进行战斗的怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttacker() end
	e:SetLabelObject(tc)
	return tc and tc:IsRelateToBattle() and tc:IsSetCard(0x66) and tc:IsType(TYPE_SYNCHRO)
end
-- ①效果的代价处理：从手卡把这张卡送去墓地才能发动；chk==0时检查能否作为代价送去墓地，可以则执行。
function c36736723.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为①效果的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果的处理：把那只进行战斗的自己怪兽的攻击力变成2倍，直到那次伤害计算时结束。
function c36736723.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 那只进行战斗的自己怪兽的攻击力只在那次伤害计算时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的过滤条件：自己墓地1只「同调士」怪兽且能够加入手卡。
function c36736723.filter(c)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动目标选择：取对象，从自己墓地选择1只符合条件的「同调士」怪兽，并设置操作信息为加入手卡。
function c36736723.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36736723.filter(chkc) end
	-- 发动时确认自己墓地是否存在至少1只符合条件的「同调士」怪兽且能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c36736723.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出“请选择要加入手卡的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1只符合条件的「同调士」怪兽作为效果对象，并登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c36736723.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：将所选择的卡加入手卡（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：取得对象怪兽，若仍与效果关联则将其加入手卡。
function c36736723.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者的手卡，理由为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
