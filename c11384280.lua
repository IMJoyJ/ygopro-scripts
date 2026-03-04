--キャノン・ソルジャー
-- 效果：
-- 可以把自己场上存在的1只怪兽解放，给与对方基本分500分伤害。
function c11384280.initial_effect(c)
	-- 创建效果，设置效果描述为“伤害”，分类为伤害效果，属性包含以玩家为目标，类型为起动效果，发动位置为主怪兽区，设定了费用函数、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11384280,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c11384280.cost)
	e1:SetTarget(c11384280.target)
	e1:SetOperation(c11384280.operation)
	c:RegisterEffect(e1)
end
-- 费用函数定义
function c11384280.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择1张可解放的卡
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 以代價原因解放选中的卡
	Duel.Release(sg,REASON_COST)
end
-- 目标函数定义
function c11384280.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为伤害效果，对象玩家为对方，伤害值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 处理函数定义
function c11384280.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
