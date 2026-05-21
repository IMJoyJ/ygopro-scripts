--リ・バウンド
-- 效果：
-- 要让场上的卡回到手卡的效果由对方发动时才能发动。那个效果无效，从对方的手卡·场上选1张卡送去墓地。此外，盖放的这张卡被对方破坏送去墓地时，从卡组抽1张卡。
function c983995.initial_effect(c)
	-- 要让场上的卡回到手卡的效果由对方发动时才能发动。那个效果无效，从对方的手卡·场上选1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c983995.condition)
	e1:SetTarget(c983995.target)
	e1:SetOperation(c983995.operation)
	c:RegisterEffect(e1)
	-- 此外，盖放的这张卡被对方破坏送去墓地时，从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(983995,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c983995.drcon)
	e2:SetTarget(c983995.drtg)
	e2:SetOperation(c983995.drop)
	c:RegisterEffect(e2)
end
-- 发动条件：对方发动了可以被无效的、让场上的卡回到手卡的效果
function c983995.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动效果的不是对方，或者该连锁无法被无效，则不能发动
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若当前连锁是无效化效果且其对象是魔法·陷阱卡的发动，则不能发动
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁中关于“回到手卡”的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 效果1（无效并送墓）的靶子（Target）函数：检查对方手卡或场上是否有卡，并设置操作信息
function c983995.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方的手卡和场上合计是否有至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：从对方的手卡或场上将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
end
-- 效果1（无效并送墓）的操作（Operation）函数：使效果无效，并让对方选择手卡或场上的1张卡送去墓地
function c983995.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的效果，若无效失败则不处理后续效果
	if not Duel.NegateEffect(ev) then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由自身玩家从对方的手卡或场上选择1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD+LOCATION_HAND,1,1,nil)
	if g:GetCount()~=0 then
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果2（抽卡）的触发条件：盖放的这张卡被对方破坏并送去墓地
function c983995.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_DESTROY)~=0 and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果2（抽卡）的靶子（Target）函数：设置抽卡玩家、抽卡数量及操作信息
function c983995.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息：自身玩家从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果2（抽卡）的操作（Operation）函数：执行抽卡效果
function c983995.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
