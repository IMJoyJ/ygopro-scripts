--ファーニマル・ラビット
-- 效果：
-- 「毛绒动物·兔子」的效果1回合只能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只「锋利小鬼·剪刀」或者1只「毛绒动物·兔子」以外的「毛绒动物」怪兽为对象才能发动。那只怪兽加入手卡。
function c38124994.initial_effect(c)
	-- 创建效果，设置为单体诱发选发效果，具有取对象和延迟处理属性，触发时机为作为融合召唤素材被送入墓地，限制1回合1次使用
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38124994,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,38124994)
	e1:SetCondition(c38124994.condition)
	e1:SetTarget(c38124994.target)
	e1:SetOperation(c38124994.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡在墓地且因融合召唤被送入墓地
function c38124994.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end
-- 筛选条件：墓地中的「锋利小鬼·剪刀」或「毛绒动物」卡组中除兔子外的怪兽，且能加入手牌
function c38124994.filter(c)
	return (c:IsCode(30068120) or (c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and not c:IsCode(38124994)))
		and c:IsAbleToHand()
end
-- 处理目标选择：选择满足条件的1只墓地怪兽作为效果对象
function c38124994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38124994.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c38124994.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示信息：向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从己方墓地选择1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c38124994.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将本次效果处理的目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理流程：从墓地选择1只满足条件的怪兽并将其加入手牌
function c38124994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌：以效果为原因将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
