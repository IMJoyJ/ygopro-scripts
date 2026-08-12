--ナチュル・ラグウィード
-- 效果：
-- 对方在抽卡阶段以外抽卡时，可以把自己场上表侧表示存在的这张卡送去墓地，从自己卡组抽2张卡。
function c87649699.initial_effect(c)
	-- 对方在抽卡阶段以外抽卡时，可以把自己场上表侧表示存在的这张卡送去墓地，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87649699,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c87649699.condition)
	e1:SetCost(c87649699.cost)
	e1:SetTarget(c87649699.target)
	e1:SetOperation(c87649699.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：判断是否满足对方在抽卡阶段以外抽卡的条件
function c87649699.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断抽卡玩家是否为对方，且当前阶段不是抽卡阶段
	return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
-- 发动代价：将场上表侧表示的自身送去墓地
function c87649699.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果目标：验证玩家是否可以抽卡，并设置抽卡的目标玩家和张数
function c87649699.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自身是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的效果处理对象玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家抽卡2张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡效果
function c87649699.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
