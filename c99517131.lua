--生命力吸収魔術
-- 效果：
-- 将场上所有里侧守备表示的怪兽全部变成表侧表示。此时反转效果不发动。之后场上每存在1只效果怪兽，自己回复400基本分。
function c99517131.initial_effect(c)
	-- 将场上所有里侧守备表示的怪兽全部变成表侧表示。此时反转效果不发动。之后场上每存在1只效果怪兽，自己回复400基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99517131.target)
	e1:SetOperation(c99517131.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示且为效果怪兽，用于统计场上效果怪兽数量。
function c99517131.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 发动时的目标处理：确认自己场上或对方怪兽区存在至少1只怪兽可发动；统计场上表侧效果怪兽数量×400作为回复量，并记录回复玩家为自己、回复参数为计算值。
function c99517131.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：场上任一怪兽区存在至少1只怪兽（作为‘将里侧守备怪兽翻开的对象存在的判断’），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 统计双方主要怪兽区表侧表示的效果怪兽数量，乘以400得到预计回复的LP数值。
	local rec=Duel.GetMatchingGroupCount(c99517131.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*400
	-- 将本次连锁的对象玩家设置为自己（回复LP的玩家为自己）。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设置为计算出的回复数值，供效果处理时使用。
	Duel.SetTargetParam(rec)
	-- 若回复数值大于0，则设置本次连锁的操作信息为‘回复LP’效果，并记录回复对象玩家和数值，以便其他卡（如星尘龙等）进行响应判定。
	if rec>0 then Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec) end
end
-- 效果处理：选出发动时存在的所有里侧守备表示怪兽，将其全部变为表侧表示（攻击/守备表示根据原位置决定，且不触发反转效果）；然后取回连锁记录的对象玩家和回复数值，重新统计场上表侧效果怪兽数量×400，为该玩家回复LP。
function c99517131.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有里侧守备表示的怪兽（即卡面朝下的怪兽）作为将要翻开的对象。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 改变表示形式：所有对象变成表侧表示（原本表侧攻击的仍为攻击，表侧守备的仍为守备），且设置noflip=true，使反转效果不发动。
	Duel.ChangePosition(g,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,true)
	-- 获取连锁记录的对象玩家（即回复LP的玩家，为自己）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新统计场上表侧效果怪兽的数量×400，得到实际回复的LP数值（因为翻开后效果怪兽数量会变化）。
	local rec=Duel.GetMatchingGroupCount(c99517131.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*400
	-- 以效果原因让对象玩家回复LP，回复量为计算值。
	Duel.Recover(p,rec,REASON_EFFECT)
end
