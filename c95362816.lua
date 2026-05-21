--E・HERO レディ・オブ・ファイア
-- 效果：
-- 自己回合的结束阶段时，给与对方基本分自己场上表侧表示存在的名字带有「元素英雄」的怪兽数量×200的数值的伤害。
function c95362816.initial_effect(c)
	-- 自己回合的结束阶段时，给与对方基本分自己场上表侧表示存在的名字带有「元素英雄」的怪兽数量×200的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95362816,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c95362816.condition)
	e1:SetTarget(c95362816.target)
	e1:SetOperation(c95362816.operation)
	c:RegisterEffect(e1)
end
-- 结束阶段效果的发动条件函数
function c95362816.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 过滤条件：自己场上表侧表示存在的名字带有「元素英雄」的怪兽
function c95362816.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果发动时的目标选择与操作信息设置函数
function c95362816.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上表侧表示的「元素英雄」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c95362816.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置对方玩家为伤害效果的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息，表示该效果会给与对方玩家「元素英雄」怪兽数量×200的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 效果处理的执行函数
function c95362816.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前自己场上表侧表示的「元素英雄」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c95362816.filter,tp,LOCATION_MZONE,0,nil)
	-- 依效果给与目标玩家对应的伤害
	Duel.Damage(p,ct*200,REASON_EFFECT)
end
