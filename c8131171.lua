--キラー・スネーク
-- 效果：
-- 「杀人蛇」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，自己准备阶段才能发动。这张卡回到手卡。下次的对方结束阶段选自己墓地1只「杀人蛇」除外。
function c8131171.initial_effect(c)
	-- 「杀人蛇」的效果1回合只能使用1次。①：这张卡在墓地存在的场合，自己准备阶段才能发动。这张卡回到手卡。下次的对方结束阶段选自己墓地1只「杀人蛇」除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8131171,0))  --"返回手卡"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,8131171)
	e1:SetCondition(c8131171.condition)
	e1:SetTarget(c8131171.target)
	e1:SetOperation(c8131171.operation)
	c:RegisterEffect(e1)
end
-- 定义准备阶段发动效果的条件函数
function c8131171.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果发动的靶向与可行性检测函数
function c8131171.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前连锁的操作信息为：将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数，将自身加入手卡并注册下次对方结束阶段的除外效果
function c8131171.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身因效果送回手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
	-- 下次的对方结束阶段选自己墓地1只「杀人蛇」除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c8131171.rmcon)
	e1:SetOperation(c8131171.rmop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将该延迟效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义延迟除外效果的触发条件函数
function c8131171.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤自己墓地中卡名为「杀人蛇」且可以被除外的卡
function c8131171.filter(c)
	return c:IsCode(8131171) and c:IsAbleToRemove()
end
-- 定义延迟除外效果的处理函数
function c8131171.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择除外卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的「杀人蛇」
	local g=Duel.SelectMatchingCard(tp,c8131171.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
