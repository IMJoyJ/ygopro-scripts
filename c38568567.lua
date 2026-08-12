--ワンダー・クローバー
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽，从手卡把1只4星的植物族怪兽送去墓地发动。选择怪兽在同1次的战斗阶段中可以作2次攻击。这张卡发动的回合，自己场上存在的其他怪兽不能攻击宣言。
function c38568567.initial_effect(c)
	-- 创建效果对象并设置为魔法卡发动效果，可选择对象，自由连锁时点，满足条件时可发动，支付费用，选择目标，发动时处理
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c38568567.condition)
	e1:SetCost(c38568567.cost)
	e1:SetTarget(c38568567.target)
	e1:SetOperation(c38568567.operation)
	c:RegisterEffect(e1)
end
-- 判断是否能进入战斗阶段
function c38568567.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 筛选手牌中4星植物族且能作为墓地代价的怪兽
function c38568567.cfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_PLANT) and c:IsAbleToGraveAsCost()
end
-- 支付费用：从手牌中选择1只4星植物族怪兽送去墓地
function c38568567.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38568567.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽并将其加入选择组
	local g=Duel.SelectMatchingCard(tp,c38568567.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(1)
end
-- 筛选场上表侧表示且未获得额外攻击次数的怪兽
function c38568567.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 设置发动效果的目标选择处理，选择场上表侧表示的怪兽，若已支付费用则设置不能攻击效果
function c38568567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38568567.filter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c38568567.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽并将其加入目标组
	local g=Duel.SelectTarget(tp,c38568567.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetLabel()==1 then
		-- 创建场地方效果，使除目标怪兽外的其他怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c38568567.ftarget)
		e1:SetLabel(g:GetFirst():GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
		e:SetLabel(0)
	end
end
-- 发动效果处理，为选择的怪兽增加1次攻击次数
function c38568567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 创建单体效果，使目标怪兽获得1次额外攻击次数
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 设置不能攻击效果的目标条件，排除目标怪兽
function c38568567.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
