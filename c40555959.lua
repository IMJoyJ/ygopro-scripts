--ハンドレス・フェイク
-- 效果：
-- 自己场上有名字带有「永火」的怪兽表侧表示存在的场合，1回合只有1次，可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
function c40555959.initial_effect(c)
	-- 自己场上有名字带有「永火」的怪兽表侧表示存在的场合，1回合只有1次，可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c40555959.activate)
	c:RegisterEffect(e1)
	-- 手卡除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(40555959,0))  --"手卡除外"
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c40555959.remcon)
	e2:SetTarget(c40555959.remtg)
	e2:SetOperation(c40555959.remop)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件：手卡有可除外的卡、自己场上存在名字带有「永火」的怪兽、玩家选择是否发动效果
function c40555959.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家手卡是否存在至少1张可以里侧表示除外的卡
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN)
		-- 检查玩家场上是否存在至少1张名字带有「永火」的怪兽表侧表示
		and Duel.IsExistingMatchingCard(c40555959.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否要发动效果
		and Duel.SelectYesNo(tp,aux.Stringid(40555959,1)) then  --"是否要除外手卡？"
		c40555959.remop(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(40555959,2))  --"发动同时使用效果"
	end
end
-- 名字带有「永火」的怪兽表侧表示的过滤函数
function c40555959.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb)
end
-- 检查是否满足手卡除外效果的发动条件：自己场上存在名字带有「永火」的怪兽表侧表示
function c40555959.remcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否存在至少1张名字带有「永火」的怪兽表侧表示
	return Duel.IsExistingMatchingCard(c40555959.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置手卡除外效果的目标信息：将要除外的卡为玩家手卡
function c40555959.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(40555959)==0
		-- 检查玩家手卡是否存在至少1张可以里侧表示除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN) end
	-- 设置操作信息：将要除外的卡为玩家手卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	e:GetHandler():RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 执行手卡除外效果：将玩家手卡中所有可里侧表示除外的卡除外
function c40555959.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手卡中所有可里侧表示除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil,tp,POS_FACEDOWN)
	if g:GetCount()>0 then
		-- 将指定卡组中的卡以里侧表示从游戏中除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		-- 设置一个在准备阶段触发的效果，用于在下次准备阶段时将除外的卡送回手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,1)
		e1:SetCountLimit(1)
		e1:SetLabel(c40555959.counter)
		e1:SetCondition(c40555959.retcon)
		e1:SetOperation(c40555959.retop)
		e1:SetLabelObject(g)
		-- 将效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
		g:KeepAlive()
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end
	end
end
-- 用于判断卡是否被除外效果标记的过滤函数
function c40555959.retfilter(c)
	return c:GetFlagEffect(40555959)~=0
end
-- 准备阶段触发效果的条件函数：判断当前回合玩家是否为效果持有者
function c40555959.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段触发效果的执行函数：将标记的卡送回手卡
function c40555959.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c40555959.retfilter,nil)
	g:DeleteGroup()
	if sg:GetCount()>0 then
		-- 将指定卡组中的卡送回玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
