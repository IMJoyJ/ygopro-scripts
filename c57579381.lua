--堕天使マリー
-- 效果：
-- 只要这张卡在墓地存在，每次的自己的准备阶段自己回复200基本分。
function c57579381.initial_effect(c)
	-- 只要这张卡在墓地存在，每次的自己的准备阶段自己回复200基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57579381,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c57579381.condition)
	e1:SetTarget(c57579381.target)
	e1:SetOperation(c57579381.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，限制在自己的准备阶段发动
function c57579381.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果的目标处理函数，设定回复的玩家与数值
function c57579381.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数（回复量）设置为200
	Duel.SetTargetParam(200)
	-- 设置当前连锁的操作信息为：使玩家tp回复200基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,200)
end
-- 定义效果的处理函数，若此卡仍在墓地则执行回复
function c57579381.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 获取当前连锁中设定的目标玩家和回复数值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 因效果使目标玩家回复对应的基本分
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
