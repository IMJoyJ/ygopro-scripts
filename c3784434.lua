--突撃ライノス
-- 效果：
-- 1回合1次，指定没有使用的相邻的怪兽卡区域才能发动。自己场上的这张卡向那个怪兽卡区域移动。向这张卡的正对面的对方怪兽攻击的场合，伤害步骤内这张卡的攻击力上升500。
function c3784434.initial_effect(c)
	-- “1回合1次，指定没有使用的相邻的怪兽卡区域才能发动。自己场上的这张卡向那个怪兽卡区域移动。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3784434,0))  --"移动位置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c3784434.seqcon)
	e1:SetTarget(c3784434.seqtg)
	e1:SetOperation(c3784434.seqop)
	c:RegisterEffect(e1)
	-- “向这张卡的正对面的对方怪兽攻击的场合，伤害步骤内这张卡的攻击力上升500。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c3784434.atkcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否在主要怪兽区，且其左侧或右侧相邻的己方主要怪兽区域存在空位，作为起动效果的发动的条件。
function c3784434.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 检查左侧相邻怪兽区是否可用（本卡不在最左列且左一格子为空），若可用则存在可移动的左侧位置。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查右侧相邻怪兽区是否可用（本卡不在最右列且右一格子为空），若可用则存在可移动的右侧位置。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 效果发动时选择要移动到的相邻空格：先计算当前可能移动的左右相邻空格标记，再让玩家从中选择一个位置，并把选择结果存入效果的Label中供处理时使用。
function c3784434.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetHandler():GetSequence()
	local flag=0
	-- 若左侧相邻格可用，则在可选位置标记中加入左侧格子对应的位标记。
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 若右侧相邻格可用，则在可选位置标记中加入右侧格子对应的位标记。
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	-- 向操作玩家发送提示消息，提示内容为“请选择要移动到的位置”，用于选择区域时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 通过区域选择控件，让玩家在自己主要怪兽区中选择一个可移动的相邻空格（传入的~flag表示被禁用的位置，从而只允许选择之前计算出的可用邻格），返回该位置的位标记。
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	e:SetLabel(nseq)
	-- 向玩家高亮显示其选中的怪兽区域位置，作为操作反馈。
	Duel.Hint(HINT_ZONE,tp,s)
end
-- 效果处理时执行移动操作：先进行合法性校验，确认这张卡仍与效果关联、控制权未改变、仍在主要怪兽区且目标空格仍为空，然后将其移动到选定的相邻怪兽区域。
function c3784434.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	-- 移动前的合法性校验：若这张卡已与效果失去关联（如离场过）、控制权改变、已经不在主要怪兽区、或选定的目标空格已被占用，则不执行移动。
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:GetSequence()>4 or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	-- 将这张卡的所在位置移动到目标序号对应的怪兽区域，实现“自己场上的这张卡向那个怪兽卡区域移动”的效果。
	Duel.MoveSequence(c,seq)
end
-- 攻击力上升效果的适用条件：当前处于伤害步骤或伤害计算时，攻击者为这张卡，攻击对象是对方怪兽且该怪兽位于这张卡的纵列（正对面），满足时攻击力上升500。
function c3784434.atkcon(e)
	-- 获取当前阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	-- 获取当前战斗的攻击目标怪兽（直接攻击时可能没有攻击目标）。
	local at=Duel.GetAttackTarget()
	-- 判断当前是伤害步骤或伤害计算时、攻击者为这张卡且存在攻击目标，作为攻击力上升的前提条件（攻击目标是否在正对面由后续判断确定）。
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetAttacker()==c and at then
		return c:GetColumnGroup():IsContains(at)
	else return false end
end
