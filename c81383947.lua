--白魔導士ピケル
-- 效果：
-- 在自己的准备阶段时，回复数值与自己场上存在的怪兽数量×400点等同的基本分。
function c81383947.initial_effect(c)
	-- 在自己的准备阶段时，回复数值与自己场上存在的怪兽数量×400点等同的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81383947,0))  --"回复LP"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c81383947.condition)
	e1:SetTarget(c81383947.target)
	e1:SetOperation(c81383947.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件
function c81383947.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是自己（即在自己的准备阶段）
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动时的目标确认与操作信息设置
function c81383947.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己场上怪兽区域的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 将效果的目标玩家设定为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的操作信息为：回复自己（怪兽数量×400）的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*400)
end
-- 定义效果处理的具体执行逻辑
function c81383947.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算效果处理时自己场上怪兽区域的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 执行回复操作，使目标玩家回复对应的基本分
	Duel.Recover(p,ct*400,REASON_EFFECT)
end
