--抹殺の邪悪霊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽攻击的伤害步骤开始时，把自己的手卡·场上的这张卡送去墓地，以自己墓地1只恶魔族·8星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
-- ②：这张卡在墓地存在，恶魔族·8星怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
function c51993760.initial_effect(c)
	-- ①：对方怪兽攻击的伤害步骤开始时，把自己的手卡·场上的这张卡送去墓地，以自己墓地1只恶魔族·8星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51993760,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,51993760)
	e1:SetCondition(c51993760.condition)
	e1:SetCost(c51993760.cost)
	e1:SetTarget(c51993760.target)
	e1:SetOperation(c51993760.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，恶魔族·8星怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51993760,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51993761)
	e2:SetCondition(c51993760.thcon)
	e2:SetTarget(c51993760.thtg)
	e2:SetOperation(c51993760.thop)
	c:RegisterEffect(e2)
end
-- 对方怪兽攻击的伤害步骤开始时才能发动此效果
function c51993760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方怪兽攻击
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 支付此效果的代价，将此卡送去墓地
function c51993760.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选满足条件的恶魔族8星怪兽
function c51993760.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标的条件和检查条件
function c51993760.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51993760.spfilter(chkc,e,tp) end
	-- 检查场上是否有特殊召唤的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c51993760.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c51993760.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理操作
function c51993760.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并进行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果被无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 获取当前攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 计算攻击伤害
			Duel.CalculateDamage(a,tc)
		end
	end
end
-- 筛选满足条件的恶魔族8星怪兽
function c51993760.cfilter(c,tp)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
-- 判断是否为恶魔族8星怪兽被送去墓地且不是此卡本身
function c51993760.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c51993760.cfilter,1,nil,tp)
end
-- 设置效果处理信息，确定将要加入手卡的卡
function c51993760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息，确定将要加入手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果处理操作
function c51993760.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
