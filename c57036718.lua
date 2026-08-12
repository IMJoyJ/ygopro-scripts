--ズバババスター
-- 效果：
-- 这张卡给与对方基本分战斗伤害的伤害步骤结束时，场上表侧表示存在的1只攻击力最低的怪兽破坏，这张卡的攻击力下降800。
function c57036718.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetOperation(c57036718.damop)
	c:RegisterEffect(e1)
	-- 伤害步骤结束时，场上表侧表示存在的1只攻击力最低的怪兽破坏，这张卡的攻击力下降800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57036718,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c57036718.descon)
	e2:SetTarget(c57036718.destg)
	e2:SetOperation(c57036718.desop)
	c:RegisterEffect(e2)
end
-- 在给与对方战斗伤害时，给自身注册一个在伤害步骤内有效的Flag标记
function c57036718.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(57036718,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 检查自身是否在伤害步骤内给与了对方战斗伤害（是否存在对应的Flag标记）
function c57036718.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(57036718)~=0
end
-- 过滤场上表侧表示的卡片
function c57036718.filter(c)
	return c:IsFaceup()
end
-- 效果发动的对象准备，获取场上攻击力最低的怪兽并设置破坏的操作信息
function c57036718.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上双方怪兽区域的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(c57036718.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local tg=g:GetMinGroup(Card.GetAttack)
	-- 设置破坏操作的信息，预计破坏1张攻击力最低的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 执行破坏场上攻击力最低的怪兽，并使自身攻击力下降800的效果
function c57036718.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上双方怪兽区域的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(c57036718.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMinGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的卡片（存在多只攻击力最低的怪兽时）
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 破坏玩家选择的那一只攻击力最低的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若只有一只攻击力最低的怪兽，则直接将其破坏
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡的攻击力下降800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
