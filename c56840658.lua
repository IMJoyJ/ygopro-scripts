--引きガエル
-- 效果：
-- 场上表侧表示的这张卡被送去墓地时，可以从自己卡组抽1张卡。
function c56840658.initial_effect(c)
	-- 场上表侧表示的这张卡被送去墓地时，可以从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56840658,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c56840658.condition)
	e2:SetTarget(c56840658.target)
	e2:SetOperation(c56840658.operation)
	c:RegisterEffect(e2)
end
-- 检查这张卡送去墓地前的位置是否在场上，且表示形式是否为表侧表示
function c56840658.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果发动的目标，确认玩家是否能抽卡，并设置抽卡的目标玩家、张数和操作信息
function c56840658.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查玩家是否具有抽1张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：让玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行，获取目标玩家和抽卡张数并执行抽卡操作
function c56840658.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
