--踊る妖精
-- 效果：
-- 只要这张卡在自己场上表侧守备表示存在，每次自己的准备阶段回复1000基本分。
function c90925163.initial_effect(c)
	-- 只要这张卡在自己场上表侧守备表示存在，每次自己的准备阶段回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90925163,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c90925163.condition)
	e1:SetTarget(c90925163.target)
	e1:SetOperation(c90925163.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数
function c90925163.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，且自身是否处于守备表示
	return tp==Duel.GetTurnPlayer() and e:GetHandler():IsDefensePos()
end
-- 定义效果发动时的目标选择与操作信息注册函数
function c90925163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前玩家（自己）设定为效果处理的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 将回复数值1000设定为效果处理的目标参数
	Duel.SetTargetParam(1000)
	-- 向系统注册操作信息：使目标玩家回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 定义效果处理（回复基本分）的执行函数
function c90925163.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_DEFENSE) then
		-- 使目标玩家回复指定数值的基本分
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
