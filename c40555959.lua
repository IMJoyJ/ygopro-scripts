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
	-- 自己场上有名字带有「永火」的怪兽表侧表示存在的场合，1回合只有1次，可以直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
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
-- 卡片发动时的处理函数：若自己手卡有可里侧除外的卡且场上有表侧表示「永火」怪兽，询问是否同时发动除外手卡效果并记录本回合使用次数标记。
function c40555959.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手卡中是否存在至少1张可以里侧表示除外的卡。
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN)
		-- 且检查自己怪兽区域是否存在至少1只表侧表示的「永火」怪兽。
		and Duel.IsExistingMatchingCard(c40555959.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 且询问玩家是否在卡片发动时同时执行除外全部手卡的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(40555959,1)) then  --"是否要除外手卡？"
		c40555959.remop(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(40555959,2))  --"发动同时使用效果"
	end
end
-- 过滤函数：判断怪兽是否为表侧表示且卡名带有「永火」字段。
function c40555959.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb)
end
-- ②效果的发动条件判定：检查自己怪兽区域是否存在至少1只表侧表示的「永火」怪兽。
function c40555959.remcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1只表侧表示的「永火」怪兽。
	return Duel.IsExistingMatchingCard(c40555959.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标处理函数（可行性检测部分）：检查本回合是否未使用过该效果（无标识）且手卡存在可里侧除外的卡。
function c40555959.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(40555959)==0
		-- 且检查自己手卡中是否存在至少1张可以里侧表示除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN) end
	-- 设置操作信息：预计从自己手卡将卡片除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	e:GetHandler():RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 除外手卡的效果处理函数：将手卡全部以里侧表示除外，为被除外的卡打上标记并注册直到下次自己准备阶段将其加入手卡的持续效果。
function c40555959.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡中所有可以里侧表示除外的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil,tp,POS_FACEDOWN)
	if g:GetCount()>0 then
		-- 将获取到的自己全部手卡以效果里侧表示除外。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		-- 直到下次的自己的准备阶段时把自己手卡全部里侧表示从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,1)
		e1:SetCountLimit(1)
		e1:SetCondition(c40555959.retcon)
		e1:SetOperation(c40555959.retop)
		e1:SetLabelObject(g)
		-- 为自己注册一个在下次自己准备阶段触发的全局持续效果，用于取回除外的手卡。
		Duel.RegisterEffect(e1,tp)
		g:KeepAlive()
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(40555959,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end
	end
end
-- 过滤函数：判断卡片是否仍保有由本卡除外时附带的标识效果。
function c40555959.retfilter(c)
	return c:GetFlagEffect(40555959)~=0
end
-- 归还手卡效果的触发条件判定：检查当前回合玩家是否为自己。
function c40555959.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否轮到自己玩家。
	return Duel.GetTurnPlayer()==tp
end
-- 归还手卡的效果处理函数：从记录的卡片组中筛选仍带有除外标识的卡，将其送回手卡并释放卡片组内存。
function c40555959.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c40555959.retfilter,nil)
	g:DeleteGroup()
	if sg:GetCount()>0 then
		-- 将仍处于该效果除外状态的卡片以效果送回各自持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
