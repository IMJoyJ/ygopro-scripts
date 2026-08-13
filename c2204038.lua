--ワルキューレ・ヴリュンヒルデ
-- 效果：
-- ①：这张卡的攻击力上升对方场上的怪兽数量×500。
-- ②：这张卡不受对方的魔法卡的效果影响。
-- ③：对方怪兽的攻击宣言时才能发动。这张卡的守备力下降1000，这个回合，自己的「女武神」怪兽不会被战斗破坏。
function c2204038.initial_effect(c)
	-- 对应效果原文：②：这张卡不受对方的魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c2204038.efilter)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：这张卡的攻击力上升对方场上的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c2204038.atkval)
	c:RegisterEffect(e2)
	-- 对应效果原文：③：对方怪兽的攻击宣言时才能发动。这张卡的守备力下降1000，这个回合，自己的「女武神」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2204038,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c2204038.ptcon)
	e3:SetTarget(c2204038.pttg)
	e3:SetOperation(c2204038.ptop)
	c:RegisterEffect(e3)
end
-- 免疫效果的判定函数：所免疫的效果必须是魔法卡类型，且该效果的持有者不是本卡当前控制者（即对方发动的魔法卡的效果），满足时本卡不受该效果影响。
function c2204038.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 计算攻击力上升值的函数：以这张卡的控制者为视角，统计对方场上的怪兽数量并乘以500，作为攻击力上升数值。
function c2204038.atkval(e,c)
	-- 获取此卡控制者对方场上的怪兽数量并乘以500，作为攻击力上升值。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*500
end
-- ③效果的发动条件：当前攻击宣言的怪兽是对方的怪兽，且该怪兽仍与本次战斗关联（正常进行攻击），满足时才可发动。
function c2204038.ptcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and at:IsRelateToBattle()
end
-- ③效果的发动合法检查：确认本卡当前守备力不低于1000，否则不能发动（该效果不取对象，此函数仅作发动条件校验）。
function c2204038.pttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDefense()>=1000 end
end
-- ③效果处理：若本卡仍与此连锁相关且为表侧表示、守备力不低于1000，则使其守备力下降1000，并给自己场上的全部「女武神」怪兽赋予本回合内不会被战斗破坏的效果。
function c2204038.ptop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetDefense()>=1000 then
		-- 对应效果原文：③：……这张卡的守备力下降1000……
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
		-- 对应效果原文：③：……这个回合，自己的「女武神」怪兽不会被战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTarget(c2204038.ptfilter)
		e2:SetValue(1)
		-- 向决斗注册这个场地效果（e2），归属玩家为tp，使我方怪兽区上的「女武神」怪兽在本回合获得不会被战斗破坏的效果。
		Duel.RegisterEffect(e2,tp)
	end
end
-- ③效果中战斗破坏免疫的筛选函数：仅对持有「女武神」字段（0x122）的怪兽适用。
function c2204038.ptfilter(e,c)
	return c:IsSetCard(0x122)
end
