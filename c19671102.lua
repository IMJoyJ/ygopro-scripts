--メールの階段
-- 效果：
-- ①：自己主要阶段才能把这个效果发动。从手卡丢弃1张「廷达魔三角」卡，从以下效果选1个适用。这个回合，和这个效果丢弃的卡同名的卡不能用自己的「奇迹螺旋阶梯」的效果丢弃。
-- ●选自己场上1只里侧守备表示怪兽变成表侧攻击表示。
-- ●选自己场上1只表侧攻击表示怪兽变成里侧守备表示。
function c19671102.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己主要阶段才能把这个效果发动。从手卡丢弃1张「廷达魔三角」卡，从以下效果选1个适用。这个回合，和这个效果丢弃的卡同名的卡不能用自己的「奇迹螺旋阶梯」的效果丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19671102,0))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c19671102.postg)
	e2:SetOperation(c19671102.posop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「廷达魔三角」卡，且该卡可以被丢弃，且该卡未被此效果限制丢弃。
function c19671102.filter(c)
	return c:IsSetCard(0x10b) and c:IsDiscardable(REASON_EFFECT) and not c:IsHasEffect(19671102)
end
-- 检索满足条件的场上怪兽，该怪兽可以改变表示形式。
function c19671102.posfilter(c)
	return (c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition())
		or (c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanTurnSet())
end
-- 判断是否满足发动条件，即手卡有「廷达魔三角」卡且场上存在可改变表示形式的怪兽。
function c19671102.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡是否存在满足条件的「廷达魔三角」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c19671102.filter,tp,LOCATION_HAND,0,1,nil)
		-- 判断场上是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c19671102.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，表示将要丢弃一张手卡。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行丢弃卡和改变怪兽表示形式的操作。
function c19671102.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的手卡。
	local g=Duel.SelectMatchingCard(tp,c19671102.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡送入墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择满足条件的场上怪兽。
		local pg=Duel.SelectMatchingCard(tp,c19671102.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if pg:GetCount()>0 then
			-- 显示选中的怪兽被选为对象的动画效果。
			Duel.HintSelection(pg)
			local pc=pg:GetFirst()
			if pc:IsFacedown() then
				-- 将选中的怪兽变为表侧攻击表示。
				Duel.ChangePosition(pc,POS_FACEUP_ATTACK)
			else
				-- 将选中的怪兽变为里侧守备表示。
				Duel.ChangePosition(pc,POS_FACEDOWN_DEFENSE)
			end
		end
	end
	if tc then
		local code=tc:GetCode()
		-- 效果原文内容：●选自己场上1只里侧守备表示怪兽变成表侧攻击表示。●选自己场上1只表侧攻击表示怪兽变成里侧守备表示。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(19671102)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetLabel(code)
		e1:SetTarget(c19671102.dhlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册一个永续效果，限制本回合内不能用此卡效果丢弃同名卡。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件函数，判断卡是否为被丢弃的卡的同名卡。
function c19671102.dhlimit(e,c)
	return c:IsCode(e:GetLabel())
end
