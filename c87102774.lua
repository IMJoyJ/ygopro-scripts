--黄金の天道虫
-- 效果：
-- 自己的准备阶段时，可以把手卡的这张卡给对方玩家观看，自己回复500基本分。这个效果使用的场合，直到结束阶段时把手卡的这张卡公开。这个效果1回合只能使用1次。
function c87102774.initial_effect(c)
	-- 自己的准备阶段时，可以把手卡的这张卡给对方玩家观看，自己回复500基本分。这个效果使用的场合，直到结束阶段时把手卡的这张卡公开。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87102774,0))  --"回复"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c87102774.reccon)
	e1:SetCost(c87102774.reccost)
	e1:SetTarget(c87102774.rectg)
	e1:SetOperation(c87102774.recop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，判断是否在自己的准备阶段
function c87102774.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果发动代价函数，将手牌中的这张卡公开直到结束阶段
function c87102774.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	-- 这个效果使用的场合，直到结束阶段时把手卡的这张卡公开
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(66)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 定义效果发动目标函数，设置回复对象和回复数值
function c87102774.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为回复自己500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 定义效果处理函数，执行回复基本分的操作
function c87102774.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
