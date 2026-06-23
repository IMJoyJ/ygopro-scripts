--灼熱王パイロン
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●可以给与对方基本分1000分伤害。这个效果1回合只能使用1次。
function c20438745.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●可以给与对方基本分1000分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20438745,0))  --"1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 效果的发动条件为该怪兽处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c20438745.target)
	e1:SetOperation(c20438745.operation)
	c:RegisterEffect(e1)
end
-- 设置效果的目标玩家为对方玩家，伤害值为1000
function c20438745.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理时的目标参数为1000点伤害
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果发动时执行的处理函数，用于实际造成伤害
function c20438745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定点数的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
