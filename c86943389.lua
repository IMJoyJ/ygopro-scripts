--HSR快刀乱破ズール
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡和特殊召唤的怪兽进行战斗的伤害步骤开始时才能发动。这张卡的攻击力直到那次伤害步骤结束时变成2倍。
-- ②：同调召唤的这张卡被送去墓地的回合的结束阶段，以「高速疾行机人 快刀乱破智游」以外的自己墓地1只「疾行机人」怪兽为对象才能发动。那只怪兽加入手卡。
function c86943389.initial_effect(c)
	-- 添加同调召唤手续（1只调整+1只以上调整以外的怪兽）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡和特殊召唤的怪兽进行战斗的伤害步骤开始时才能发动。这张卡的攻击力直到那次伤害步骤结束时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86943389,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c86943389.atkcon)
	e1:SetOperation(c86943389.atkop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c86943389.regcon)
	e2:SetOperation(c86943389.regop)
	c:RegisterEffect(e2)
	-- ②：同调召唤的这张卡被送去墓地的回合的结束阶段，以「高速疾行机人 快刀乱破智游」以外的自己墓地1只「疾行机人」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86943389,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c86943389.thcon)
	e3:SetTarget(c86943389.thtg)
	e3:SetOperation(c86943389.thop)
	c:RegisterEffect(e3)
end
-- 判定这张卡是否与特殊召唤的怪兽进行战斗
function c86943389.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 伤害步骤开始时，使这张卡的攻击力直到伤害步骤结束时变成2倍
function c86943389.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到那次伤害步骤结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 判定是否为同调召唤的这张卡从怪兽区域送去墓地
function c86943389.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 在送去墓地时，为自身注册一个在回合结束阶段前有效的Flag，用于标记该回合被送去墓地
function c86943389.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(86943389,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判定这张卡在当前回合是否被送去墓地（检查是否存在对应的Flag）
function c86943389.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(86943389)>0
end
-- 过滤自己墓地中「高速疾行机人 快刀乱破智游」以外的「疾行机人」怪兽
function c86943389.thfilter(c)
	return c:IsSetCard(0x2016) and not c:IsCode(86943389) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 结束阶段效果的发动准备，确认墓地中存在合法的目标怪兽，并进行取对象和设置操作信息
function c86943389.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86943389.thfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的「疾行机人」怪兽
	if chk==0 then return Duel.IsExistingTarget(c86943389.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的「疾行机人」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86943389.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为“将选中的1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 结束阶段效果的处理，将作为对象的怪兽加入手牌
function c86943389.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
