--瑚之龍
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
function c42566602.initial_effect(c)
	-- 为该卡添加同调召唤手续：1只调整＋1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42566602,0))  --"卡片破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c42566602.cost)
	e1:SetTarget(c42566602.target)
	e1:SetOperation(c42566602.operation)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42566602,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,42566602)
	e2:SetCondition(c42566602.drcon)
	e2:SetTarget(c42566602.drtg)
	e2:SetOperation(c42566602.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动代价：从手卡丢弃1张卡作为发动代价。
function c42566602.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：选择并丢弃1张手卡，丢弃原因视为代价与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果的发动对象选择：必须以对方场上1张卡为对象。
function c42566602.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 对象检测：确认对方场上存在至少1张能够成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示信息，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏，登记该次效果处理将破坏的对象卡及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义①效果处理时的实际动作：破坏发动时选择的对象卡。
function c42566602.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中登记的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡此前位于主要怪兽区，且以同调召唤方式召唤过。
function c42566602.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义②效果的发动条件与处理参数：设置抽卡玩家、抽卡数量及操作信息。
function c42566602.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 抽卡检测：确认该玩家能够通过效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为发动玩家（即自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为抽卡数量1。
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡，预计抽卡数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义②效果处理时的实际动作：执行抽卡。
function c42566602.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中记录的对象玩家和参数，即抽卡玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
