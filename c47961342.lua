--転轍地点
-- 效果：
-- ①：对方场上有怪兽3只以上存在的场合，选那之内的1只。对方必须把以下其中任意种送去墓地。
-- ●选的怪兽
-- ●选的怪兽以外的自身场上的全部怪兽
local s,id,o=GetID()
-- 定义并注册卡片效果：创建效果e1，设置其描述、类别（送去墓地）、类型（魔法卡发动）、发动时机（自由时点）、提示时点、目标条件和处理函数，最后将效果注册到卡片上。
function s.initial_effect(c)
	-- ①：对方场上有怪兽3只以上存在的场合，选那之内的1只。对方必须把以下其中任意种送去墓地。●选的怪兽 ●选的怪兽以外的自身场上的全部怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 目标处理函数：先检查对方场上怪兽是否达到3只以上（发动合法性）；若满足，则设置本次操作信息，预告效果处理时会将对方场上1只怪兽送去墓地。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：仅在对方场上的怪兽数量大于2（即3只以上）时，效果才允许发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>2 end
	-- 设置操作信息：本次效果处理会把对方场上（1-tp）的1只怪兽送去墓地（CATEGORY_TOGRAVE），数量暂定为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果处理函数：处理时再次确认对方场上仍有3只以上怪兽；然后由自己选择对方场上1只怪兽，再让对方选择是把该怪兽送去墓地，还是把该怪兽以外的自身场上全部怪兽送去墓地。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新确认对方场上怪兽数不低于3，若已不足3只则效果不处理。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<3 then return end
	-- 给操作者（tp）显示“请选择对方的卡”的提示信息，用于下一步选择对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 从对方场上（tp的对方，LOCATION_MZONE）选择1只怪兽作为“选的怪兽”，不取对象、在处理时选择；无过滤条件（nil），可包含所有表侧/里侧怪兽。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 高亮显示并标记被选择的卡g，作为本次效果处理的对象（广义对象），以便连锁判定和时点记录。
	Duel.HintSelection(g)
	-- 给对方玩家（1-tp）显示“请选择要送去墓地的卡”的提示信息，为下一步选项做准备。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让对方玩家在两个选项中选择：把选的1只怪兽送去墓地，或把选的怪兽以外的自身场上全部怪兽送去墓地；返回选项序号存入opt。
	local opt=Duel.SelectOption(1-tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"把选的1只怪兽送去墓地/把其他全部怪兽送去墓地"
	if opt==0 then
		-- 按第一个选项执行：将之前选择的1只怪兽g以规则理由（REASON_RULE）送去对方的墓地。
		Duel.SendtoGrave(g,REASON_RULE,1-tp)
	else
		-- 获取对方场上除已选怪兽g以外的所有怪兽，构成组g2，即“选的怪兽以外的自身场上的全部怪兽”。
		local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,g)
		-- 按第二个选项执行：将组g2中的所有怪兽以规则理由（REASON_RULE）送去对方的墓地。
		Duel.SendtoGrave(g2,REASON_RULE,1-tp)
	end
end
