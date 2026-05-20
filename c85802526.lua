--プリンセス人魚
-- 效果：
-- 只要这张卡在自己场上表侧表示的存在，每次自己的准备阶段回复800基本分。
function c85802526.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示的存在，每次自己的准备阶段回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85802526,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c85802526.condition)
	e1:SetTarget(c85802526.target)
	e1:SetOperation(c85802526.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数
function c85802526.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，以确保在自己的准备阶段触发效果
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动的目标处理函数，设置回复的玩家、数值及操作信息
function c85802526.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（回复数值）设置为800
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为回复基本分，对象为自己，数值为800
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
-- 定义效果处理的执行函数，在卡片表侧表示存在时执行回复
function c85802526.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 执行回复操作，使目标玩家回复对应的基本分
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
