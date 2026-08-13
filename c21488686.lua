--サイコ・ヒーリング
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽每有1只，自己回复1000基本分。
function c21488686.initial_effect(c)
	-- 自己场上表侧表示存在的念动力族怪兽每有1只，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21488686.target)
	e1:SetOperation(c21488686.operation)
	c:RegisterEffect(e1)
end
-- 发动时的目标处理函数：确认发动条件，并将回复对象玩家设为自身、统计表侧念动力族怪兽数量以计算回复量，同时登记回复效果的操作信息。
function c21488686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上是否存在至少1只表侧表示的念动力族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21488686.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 将本效果的回复对象玩家设置为发动玩家自己（tp）。
	Duel.SetTargetPlayer(tp)
	-- 统计自己场上表侧表示的念动力族怪兽数量，乘以1000，作为预计回复的LP数值。
	local rec=Duel.GetMatchingGroupCount(c21488686.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 将计算出的预计回复量rec保存为连锁对象参数，供处理阶段获取。
	Duel.SetTargetParam(rec)
	-- 登记本次连锁的操作信息：标记为回复效果，目标玩家为自己，目标参数为预计回复量rec。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 过滤条件：卡片为表侧表示，且种族为念动力族。
function c21488686.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果处理函数：重新计算回复量并实际回复LP。
function c21488686.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新统计自己场上表侧表示的念动力族怪兽数量，乘以1000，得到实际回复LP数值。
	local rec=Duel.GetMatchingGroupCount(c21488686.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 从连锁信息中取出之前保存的目标玩家（即自己），作为实际回复对象。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果原因（REASON_EFFECT），使玩家p回复rec点基本分。
	Duel.Recover(p,rec,REASON_EFFECT)
end
