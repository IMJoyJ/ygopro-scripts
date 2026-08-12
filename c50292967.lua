--パスト・イメージ
-- 效果：
-- 自己场上有念动力族怪兽表侧表示存在的场合，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。这个效果除外的怪兽在下次的准备阶段时以相同表示形式回到对方场上。
function c50292967.initial_effect(c)
	-- 效果定义：将此卡注册为一张永续魔法卡，具有除外怪兽并使其在下次准备阶段返回的连锁效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c50292967.condition)
	e1:SetTarget(c50292967.target)
	e1:SetOperation(c50292967.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在表侧表示的念动力族怪兽
function c50292967.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 条件判断：当自己场上有念动力族怪兽表侧表示存在时，该效果才能发动
function c50292967.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：检查自己场上是否存在满足条件的念动力族怪兽
	return Duel.IsExistingMatchingCard(c50292967.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：选择对方场上1只可以除外的怪兽作为对象
function c50292967.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 效果处理：确认是否有符合条件的对方怪兽可被除外
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示信息：向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标：从对方场上选择1只怪兽作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将本次效果要处理的除外怪兽数量和对象设定为操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果发动：执行将目标怪兽除外并注册下次准备阶段返回的效果
function c50292967.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的怪兽作为目标
	local tc=Duel.GetFirstTarget()
	-- 效果处理：确认目标怪兽有效且成功将其以暂时除外形式从游戏中除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 效果注册：为下次准备阶段注册一个持续效果，使被除外的怪兽返回对方场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c50292967.retop)
		-- 效果注册：将上述效果注册到玩家全局环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回处理函数：当准备阶段触发时，将被除外的怪兽以原表示形式返回对方场上
function c50292967.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 返回操作：将指定的怪兽以原表示形式返回到对方场上
	Duel.ReturnToField(e:GetLabelObject())
end
