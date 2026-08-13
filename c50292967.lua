--パスト・イメージ
-- 效果：
-- 自己场上有念动力族怪兽表侧表示存在的场合，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。这个效果除外的怪兽在下次的准备阶段时以相同表示形式回到对方场上。
function c50292967.initial_effect(c)
	-- 自己场上有念动力族怪兽表侧表示存在的场合，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。这个效果除外的怪兽在下次的准备阶段时以相同表示形式回到对方场上。
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
-- 过滤函数：用于判断怪兽是否为表侧表示且种族为念动力族。
function c50292967.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 发动条件判定：自己场上是否存在至少1只表侧表示的念动力族怪兽。
function c50292967.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己场上是否存在至少1只满足cfilter条件（表侧表示且念动力族）的怪兽。
	return Duel.IsExistingMatchingCard(c50292967.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的取对象处理：选择对方场上1只可以除外的怪兽作为对象，并设置除外相关的操作信息。
function c50292967.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 合法性检查：对方场上是否存在至少1只可以除外的怪兽，满足条件时效果才能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择卡片的提示信息“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由发动玩家从对方场上选择1只可以除外的怪兽，将其设为效果对象并建立关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：本次效果分类为除外，处理对象为已选怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将对象怪兽从游戏中暂时除外，并在下次准备阶段将其返回对方场上的持续效果注册到场上。
function c50292967.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联后，将其以除外原因（效果+暂时）从游戏中除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 这个效果除外的怪兽在下次的准备阶段时以相同表示形式回到对方场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c50292967.retop)
		-- 将返回效果注册到当前玩家场上，使其在下次准备阶段时触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回效果的处理函数：把之前暂时除外的对象怪兽返回到场上。
function c50292967.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将LabelObject中记录的那只怪兽以离场前的表示形式返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
