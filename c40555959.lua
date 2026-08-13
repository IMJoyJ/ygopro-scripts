--ハンドレス・フェイク
-- 效果：
-- 自己场上有名字带有「永火」的怪兽表侧表示存在的场合，1回合只有1次，可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
function c40555959.initial_effect(c)
	-- 对应效果原文：自己场上有名字带有「永火」的怪兽表侧表示存在的场合，1回合只有1次，可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c40555959.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：自己场上有名字带有「永火」的怪兽表侧表示存在的场合，1回合只有1次，可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
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
-- 这张卡的发动处理：确认自己手牌可除外、场上有表侧永火怪兽，并询问玩家是否将手牌全部里侧除外；选择是则执行除外，登记本回合已使用标记，并提示对方本卡发动时同时使用了效果。
function c40555959.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手牌中是否存在至少1张可被里侧表示除外的卡，作为该效果可发动的条件之一。
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN)
		-- 检查自己场上是否存在表侧表示且带有『永火』字段的怪兽，作为该效果可发动的条件之一。
		and Duel.IsExistingMatchingCard(c40555959.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 弹出是/否选择框，让玩家确认是否发动『把手卡全部里侧除外』的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(40555959,1)) then  --"是否要除外手卡？"
		c40555959.remop(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(40555959,2))  --"发动同时使用效果"
	end
end
-- 过滤函数：判断怪兽是否表侧表示，并且卡名属于『永火』字段（0xb）。
function c40555959.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb)
end
-- 快速效果的发动条件：自己场上存在表侧表示的『永火』怪兽。
function c40555959.remcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检测自己场上是否存在满足『表侧表示且属于永火字段』条件的怪兽。
	return Duel.IsExistingMatchingCard(c40555959.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 快速效果的发动合法性检测：确认本卡本回合尚未使用过该效果（1回合1次），且自己手牌中存在可被里侧表示除外的卡。
function c40555959.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(40555959)==0
		-- 进一步确认自己手牌中存在至少1张可被以里侧表示除外的卡（该效果不取对象）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN) end
	-- 向系统声明本连锁的操作分类为『除外』，涉及自己手牌，预计处理1张，供相关卡的效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	e:GetHandler():RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 实际执行效果：取得自己手牌中所有可被里侧除外的卡并全部里侧除外；随后为这些卡注册标记，并设立在下次自己准备阶段归还手牌的延迟效果。
function c40555959.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己手牌中所有可被以里侧表示除外的卡，组成卡片组（不取对象，所以取得全部可除外手牌）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil,tp,POS_FACEDOWN)
	if g:GetCount()>0 then
		-- 将取得的卡片组以里侧表示从游戏中除外，除外原因为效果。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		-- 对应效果原文：可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,1)
		e1:SetCountLimit(1)
		e1:SetLabel(c40555959.counter)
		e1:SetCondition(c40555959.retcon)
		e1:SetOperation(c40555959.retop)
		e1:SetLabelObject(g)
		-- 将前述归还用延迟效果注册到场上，使其在满足条件时（下次自己的准备阶段）触发手牌归还。
		Duel.RegisterEffect(e1,tp)
		g:KeepAlive()
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end
	end
end
-- 过滤函数：判断卡片是否仍带有标记40555959，即仍处于被本效果里侧除外且尚未归还的状态。
function c40555959.retfilter(c)
	return c:GetFlagEffect(40555959)~=0
end
-- 归还用的启动条件：当前阶段为自己的准备阶段，才会执行手牌归还。
function c40555959.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断当前回合玩家是否为效果控制者（即是否为『自己的准备阶段』）。
	return Duel.GetTurnPlayer()==tp
end
-- 归还处理：从效果保存的卡片组中筛选出仍带标记的卡，将其返回持有者手牌，同时删除该卡片组。
function c40555959.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c40555959.retfilter,nil)
	g:DeleteGroup()
	if sg:GetCount()>0 then
		-- 将筛选出的卡组中的所有卡加入其持有者的手牌，归还原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
