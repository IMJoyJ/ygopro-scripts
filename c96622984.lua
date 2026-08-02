--捕食植物フライ・ヘル
-- 效果：
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后，这张卡的等级上升破坏的那只怪兽的原本等级数值。
function c96622984.initial_effect(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96622984,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c96622984.target)
	e1:SetOperation(c96622984.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96622984,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(c96622984.destg)
	e2:SetOperation(c96622984.desop)
	c:RegisterEffect(e2)
end
c96622984.mentioned_counter={
	[0x1041]=true,
}
-- 判断是否存在符合条件的对象，并给玩家提示选择怪兽
function c96622984.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1041,1) end
	-- 检查对方场上是否存在可以放置捕食指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 给玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 执行处理阶段：放置指示物，并改变怪兽的等级
function c96622984.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:IsLevelAbove(2) then
		-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c96622984.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 判断怪兽是否有捕食指示物放置
function c96622984.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 判断目标怪兽是否合法，并设置操作信息
function c96622984.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsLevelBelow(c:GetLevel()) end
	-- 设置操作信息：包含破坏效果，对象为进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行处理阶段：破坏怪兽，并上升这张卡的等级
function c96622984.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	-- 如果对方怪兽在战斗中，并且成功被效果破坏
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 那之后，这张卡的等级上升破坏的那只怪兽的原本等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
