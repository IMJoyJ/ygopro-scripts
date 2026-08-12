--希望の記憶
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己从卡组抽出自己场上的「No.」超量怪兽种类的数量。
function c84731222.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己从卡组抽出自己场上的「No.」超量怪兽种类的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,84731222+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c84731222.target)
	e1:SetOperation(c84731222.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示的「No.」超量怪兽
function c84731222.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- 效果发动的目标确认与准备阶段，计算场上「No.」超量怪兽的种类数量并设置抽卡参数
function c84731222.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示的「No.」超量怪兽卡片组
	local g=Duel.GetMatchingGroup(c84731222.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 在发动检测阶段，确认场上存在「No.」超量怪兽且自己可以进行对应数量的抽卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为抽卡数量（「No.」超量怪兽的种类数）
	Duel.SetTargetParam(ct)
	-- 设置效果处理的操作信息为：玩家tp从卡组抽ct张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理阶段，获取目标玩家并根据当前场上的「No.」超量怪兽种类数执行抽卡
function c84731222.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理时，重新获取自己场上表侧表示的「No.」超量怪兽卡片组
	local g=Duel.GetMatchingGroup(c84731222.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 让目标玩家因效果从卡组抽出对应数量的卡
	Duel.Draw(p,ct,REASON_EFFECT)
end
