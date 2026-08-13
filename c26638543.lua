--メトロンノーム
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，以这张卡以外的自己或者对方的灵摆区域1张卡为对象才能发动。这张卡的灵摆刻度直到回合结束时变成和那张卡的灵摆刻度相同。
-- 【怪兽效果】
-- ①：自己的灵摆区域有2张卡存在，那些灵摆刻度相同的场合，这张卡的攻击力·守备力上升那个灵摆刻度×100，这张卡可以直接攻击。
-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。双方的灵摆区域的卡全部破坏。
function c26638543.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性，使其可以进行灵摆召唤以及作为灵摆卡在灵摆区域发动。
	aux.EnablePendulumAttribute(c)
	-- ←4 【灵摆】 4→ ①：1回合1次，以这张卡以外的自己或者对方的灵摆区域1张卡为对象才能发动。这张卡的灵摆刻度直到回合结束时变成和那张卡的灵摆刻度相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26638543,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c26638543.sctg)
	e1:SetOperation(c26638543.scop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：自己的灵摆区域有2张卡存在，那些灵摆刻度相同的场合，这张卡的攻击力·守备力上升那个灵摆刻度×100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c26638543.con)
	e2:SetValue(c26638543.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 【怪兽效果】①：自己的灵摆区域有2张卡存在，那些灵摆刻度相同的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c26638543.con)
	c:RegisterEffect(e4)
	-- 【怪兽效果】②：这张卡直接攻击给与对方战斗伤害的场合发动。双方的灵摆区域的卡全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(26638543,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
	e5:SetCondition(c26638543.descon)
	e5:SetTarget(c26638543.destg)
	e5:SetOperation(c26638543.desop)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断灵摆区域候选卡c的左刻度是否与本卡pc的左刻度不同，用于筛选可以成为对象的灵摆卡（要求刻度不同才能改变）。
function c26638543.scfilter(c,pc)
	return c:GetLeftScale()~=pc:GetLeftScale()
end
-- 目标选择函数：发动时检查可选择的合法对象，并提示玩家从双方灵摆区域选择1张本卡以外的、左刻度不同的灵摆卡作为对象。
function c26638543.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c26638543.scfilter(chkc,c) and chkc~=c end
	-- 发动条件检查：确认双方灵摆区域存在至少1张满足“左刻度不同且不是本卡”的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c26638543.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,c,c) end
	-- 向操作玩家发送选择提示消息，提示内容为“请选择效果的对象”，用于目标选择交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方灵摆区域选择1张符合条件的灵摆卡作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c26638543.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,c,c)
end
-- 效果处理：若本卡仍在场上且与效果关联，则获取所选对象，为本卡临时注册左刻度变为对象左刻度、右刻度变为对象右刻度的效果，作用持续到回合结束时。
function c26638543.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁效果处理时选择的对象卡（即目标灵摆卡）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		-- 这张卡的灵摆刻度直到回合结束时变成和那张卡的灵摆刻度相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(tc:GetLeftScale())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(tc:GetRightScale())
		c:RegisterEffect(e2)
	end
end
-- 条件判断：己方灵摆区域有2张卡，且左灵摆区的左刻度等于右灵摆区的右刻度，即两张灵摆卡刻度相同。
function c26638543.con(e)
	local tp=e:GetHandler():GetControler()
	-- 获取己方灵摆区域第1个格的灵摆卡（左侧灵摆区）。
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取己方灵摆区域第2个格的灵摆卡（右侧灵摆区）。
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not tc1 or not tc2 then return false end
	return tc1:GetLeftScale()==tc2:GetRightScale()
end
-- 攻击力/守备力上升值计算：返回己方灵摆区域第1张卡的左刻度乘以100。
function c26638543.val(e,c)
	-- 获取该卡控制者灵摆区域第1张卡，用于读取其左刻度。
	local tc=Duel.GetFieldCard(c:GetControler(),LOCATION_PZONE,0)
	return tc:GetLeftScale()*100
end
-- 直接攻击造成战斗伤害的触发条件：战斗伤害由对方承受且该次攻击为直接攻击（没有攻击对象）。
function c26638543.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：受到战斗伤害的玩家不是此卡控制者（即对方），且本次战斗是直接攻击。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 破坏效果的发动确认与信息设置：满足条件后必然发动，并登记将双方灵摆区域所有卡破坏的操作信息。
function c26638543.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方灵摆区域的所有卡（包括自己和对方的灵摆卡），作为破坏对象组。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 设置当前连锁的操作信息：破坏类别，对象为双方灵摆区所有卡，数量为组内卡数，用于连锁判定与效果登记。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：再次获取双方灵摆区域所有卡，若存在卡片则将其全部破坏，破坏原因为效果。
function c26638543.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取双方灵摆区域的所有卡（可能因处理前变动而重新获取）。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	if g:GetCount()>0 then
		-- 将对象组中的所有卡破坏，破坏原因为效果，送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
