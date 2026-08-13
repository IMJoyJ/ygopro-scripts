--イタチの大暴発
-- 效果：
-- ①：对方场上的表侧表示怪兽的攻击力合计数值比自己基本分高的场合才能发动。直到对方场上的表侧表示怪兽的攻击力合计数值变成自己基本分以下为止，对方必须选自身场上的攻击力是0以外的表侧表示怪兽回到持有者卡组。
function c31044787.initial_effect(c)
	-- ①：对方场上的表侧表示怪兽的攻击力合计数值比自己基本分高的场合才能发动。直到对方场上的表侧表示怪兽的攻击力合计数值变成自己基本分以下为止，对方必须选自身场上的攻击力是0以外的表侧表示怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c31044787.condition)
	e1:SetTarget(c31044787.target)
	e1:SetOperation(c31044787.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：选出对方场上表侧表示、攻击力大于0且该怪兽的控制者可以将它送去卡组的怪兽。
function c31044787.filter(c,tp)
	-- 判定条件：怪兽必须表侧表示、攻击力大于0，且控制者可以将其送去卡组。
	return c:IsFaceup() and c:GetAttack()>0 and Duel.IsPlayerCanSendtoDeck(tp,c)
end
-- 发动条件：对方场上满足筛选条件的怪兽攻击力合计值高于我方基本分时才可发动。
function c31044787.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方主要怪兽区中所有满足筛选条件的表侧表示怪兽，作为候选集合。
	local g=Duel.GetMatchingGroup(c31044787.filter,tp,0,LOCATION_MZONE,nil,1-tp)
	local atk=g:GetSum(Card.GetAttack)
	-- 比较攻击力合计值与基本分，若攻击力合计值更大则发动条件成立。
	return atk>Duel.GetLP(tp)
end
-- 目标处理：本效果不取对象，满足条件即可发动，并写入回卡组的操作信息。
function c31044787.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计将对方场上怪兽送回卡组，目标玩家为对方，位置为怪兽区，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
end
-- 获取怪兽的攻击力作为选择权重；若攻击力超过0xffff，则转换为32位有符号整数表示以避免溢出。
function c31044787.getAttack(c)
	local atk=c:GetAttack()
	if atk>0xffff then atk=(atk&0x7fffffff)|0x80000000 end
	return atk
end
-- 效果处理：重新获取对方场上符合条件的怪兽，计算攻击力合计与基本分的差值；若差值不大于0则直接结束；否则提示对方选择攻击力合计不小于差值的怪兽，并将这些怪兽返回持有者卡组后洗牌。
function c31044787.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上当前满足条件的表侧表示怪兽集合，在效果处理时确定对象。
	local g=Duel.GetMatchingGroup(c31044787.filter,tp,0,LOCATION_MZONE,nil,1-tp)
	local atk=g:GetSum(Card.GetAttack)
	-- 获取我方当前基本分数值 lp。
	local lp=Duel.GetLP(tp)
	local diff=atk-lp
	if diff<=0 then return end
	-- 向对方发送选择提示，提示内容为‘请选择要返回卡组的卡’。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectWithSumGreater(1-tp,c31044787.getAttack,diff)
	-- 将选中的怪兽以规则原因送回持有者卡组，并执行洗牌。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_RULE,1-tp)
end
