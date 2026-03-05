--ヒステリック天使
-- 效果：
-- 用自己场上2只怪兽做祭品，自己的基本分回复1000分。
function c21297224.initial_effect(c)
	-- 用自己场上2只怪兽做祭品，自己的基本分回复1000分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21297224,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c21297224.cost)
	e1:SetTarget(c21297224.target)
	e1:SetOperation(c21297224.operation)
	c:RegisterEffect(e1)
end
-- 检查并选择2只怪兽进行解放作为效果的代价
function c21297224.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少2张可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 选择2只满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将选中的怪兽从场上解放并视为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标玩家和回复的LP值
function c21297224.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的目标玩家为效果使用者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理时的目标参数为1000点LP
	Duel.SetTargetParam(1000)
	-- 设置效果操作信息为回复LP效果，目标为使用者，回复1000点
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行效果的处理函数，使玩家回复指定点数的LP
function c21297224.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（回复LP值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数量的LP，原因设为效果
	Duel.Recover(p,d,REASON_EFFECT)
end
