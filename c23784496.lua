--魔界台本「オープニング・セレモニー」
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己回复自己场上的「魔界剧团」怪兽数量×500基本分。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。自己直到手卡变成5张为止从卡组抽卡。
function c23784496.initial_effect(c)
	-- ①：自己回复自己场上的「魔界剧团」怪兽数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,23784496)
	e1:SetTarget(c23784496.target)
	e1:SetOperation(c23784496.operation)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。自己直到手卡变成5张为止从卡组抽卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,23784497)
	e2:SetCondition(c23784496.drcon)
	e2:SetTarget(c23784496.drtg)
	e2:SetOperation(c23784496.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「魔界剧团」怪兽
function c23784496.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- 效果处理时的处理函数，计算回复基本分数值并设置效果对象
function c23784496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上「魔界剧团」怪兽数量并乘以500作为回复基本分
	local rec=Duel.GetMatchingGroupCount(c23784496.filter1,tp,LOCATION_MZONE,0,nil)*500
	if chk==0 then return rec>0 end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为回复的基本分
	Duel.SetTargetParam(rec)
	-- 设置效果处理信息为回复基本分效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理函数，执行回复基本分效果
function c23784496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上「魔界剧团」怪兽数量并乘以500作为回复基本分
	local rec=Duel.GetMatchingGroupCount(c23784496.filter1,tp,LOCATION_MZONE,0,nil)*500
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行回复基本分效果
	Duel.Recover(p,rec,REASON_EFFECT)
end
-- 过滤函数，用于判断额外卡组是否存在「魔界剧团」灵摆怪兽
function c23784496.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
end
-- 效果发动条件函数，判断是否满足②效果发动条件
function c23784496.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查额外卡组是否存在表侧表示的「魔界剧团」灵摆怪兽
		and Duel.IsExistingMatchingCard(c23784496.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 效果处理时的处理函数，计算抽卡数量并设置效果对象
function c23784496.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算需要抽卡的数量，直到手牌数量达到5张
	local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 检查是否可以抽卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量
	Duel.SetTargetParam(ct)
	-- 设置效果处理信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理函数，执行抽卡效果
function c23784496.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算需要抽卡的数量，直到手牌数量达到5张
	local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 then
		-- 执行抽卡效果
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
