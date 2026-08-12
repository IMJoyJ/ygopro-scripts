--デンジャラスマシン TYPE－6
-- 效果：
-- 每次自己的准备阶段丢1个骰子，根据丢出的数目决定效果。
-- ●投掷1的场合：自己丢弃1张手卡。
-- ●投掷2的场合：对方丢弃1张手卡。
-- ●投掷3的场合：自己抽1张卡。
-- ●投掷4的场合：对方抽1张卡。
-- ●投掷5的场合：对方的场上1只怪兽破坏。
-- ●投掷6的场合：这张卡破坏。
function c76895648.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己的准备阶段丢1个骰子，根据丢出的数目决定效果。●投掷1的场合：自己丢弃1张手卡。●投掷2的场合：对方丢弃1张手卡。●投掷3的场合：自己抽1张卡。●投掷4的场合：对方抽1张卡。●投掷5的场合：对方的场上1只怪兽破坏。●投掷6的场合：这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76895648,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DRAW+CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c76895648.condition)
	e2:SetTarget(c76895648.target)
	e2:SetOperation(c76895648.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动的条件函数
function c76895648.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动的目标处理函数
function c76895648.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为需要投掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 定义效果运行的具体操作函数，根据掷骰子的结果执行对应的分支效果
function c76895648.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷1次骰子并获取结果
	local dice=Duel.TossDice(tp,1)
	if dice==1 then
		-- 让玩家自己选择并丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	elseif dice==2 then
		-- 让对方玩家选择并丢弃1张手卡
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	elseif dice==3 then
		-- 让玩家自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif dice==4 then
		-- 让对方玩家抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	elseif dice==5 then
		-- 在系统提示栏显示“请选择要破坏的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方怪兽区域的1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		-- 破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	elseif dice==6 then
		-- 破坏这张卡自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
