--突撃ライノス
-- 效果：
-- 1回合1次，指定没有使用的相邻的怪兽卡区域才能发动。自己场上的这张卡向那个怪兽卡区域移动。向这张卡的正对面的对方怪兽攻击的场合，伤害步骤内这张卡的攻击力上升500。
function c3784434.initial_effect(c)
	-- 1回合1次，指定没有使用的相邻的怪兽卡区域才能发动。自己场上的这张卡向那个怪兽卡区域移动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3784434,0))  --"移动位置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c3784434.seqcon)
	e1:SetTarget(c3784434.seqtg)
	e1:SetOperation(c3784434.seqop)
	c:RegisterEffect(e1)
	-- 向这张卡的正对面的对方怪兽攻击的场合，伤害步骤内这张卡的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c3784434.atkcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
-- 检查当前怪兽卡区域是否可以移动到相邻区域
function c3784434.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 检查左侧相邻区域是否可用
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查右侧相邻区域是否可用
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 选择并设置目标移动区域
function c3784434.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetHandler():GetSequence()
	local flag=0
	-- 标记左侧相邻区域为不可选
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 标记右侧相邻区域为不可选
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	-- 提示玩家选择移动位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个可用的怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	e:SetLabel(nseq)
	-- 显示选择的区域
	Duel.Hint(HINT_ZONE,tp,s)
end
-- 执行怪兽卡移动操作
function c3784434.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	-- 检查卡是否仍然有效且在正确位置
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:GetSequence()>4 or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	-- 将怪兽卡移动到指定区域
	Duel.MoveSequence(c,seq)
end
-- 判断是否处于伤害步骤并确认攻击目标
function c3784434.atkcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	-- 获取攻击目标怪兽
	local at=Duel.GetAttackTarget()
	-- 判断是否处于伤害步骤且为攻击怪兽
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetAttacker()==c and at then
		return c:GetColumnGroup():IsContains(at)
	else return false end
end
