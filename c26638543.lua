--メトロンノーム
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，以这张卡以外的自己或者对方的灵摆区域1张卡为对象才能发动。这张卡的灵摆刻度直到回合结束时变成和那张卡的灵摆刻度相同。
-- 【怪兽效果】
-- ①：自己的灵摆区域有2张卡存在，那些灵摆刻度相同的场合，这张卡的攻击力·守备力上升那个灵摆刻度×100，这张卡可以直接攻击。
-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。双方的灵摆区域的卡全部破坏。
function c26638543.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己或者对方的灵摆区域1张卡为对象才能发动。这张卡的灵摆刻度直到回合结束时变成和那张卡的灵摆刻度相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26638543,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c26638543.sctg)
	e1:SetOperation(c26638543.scop)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆区域有2张卡存在，那些灵摆刻度相同的场合，这张卡的攻击力·守备力上升那个灵摆刻度×100，这张卡可以直接攻击。
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
	-- ①：自己的灵摆区域有2张卡存在，那些灵摆刻度相同的场合，这张卡的攻击力·守备力上升那个灵摆刻度×100，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c26638543.con)
	c:RegisterEffect(e4)
	-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。双方的灵摆区域的卡全部破坏。
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
-- 筛选目标灵摆卡，其左刻度与当前卡的左刻度不同
function c26638543.scfilter(c,pc)
	return c:GetLeftScale()~=pc:GetLeftScale()
end
-- 设置效果目标为灵摆区域中左刻度与当前卡不同的1张卡
function c26638543.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c26638543.scfilter(chkc,c) and chkc~=c end
	-- 检查是否存在符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c26638543.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,c,c) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的目标卡
	Duel.SelectTarget(tp,c26638543.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,c,c)
end
-- 将当前卡的灵摆刻度修改为所选目标卡的刻度
function c26638543.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		-- 创建一个修改左刻度的效果并注册
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
-- 判断当前玩家的灵摆区域是否有两张卡且左刻度等于右刻度
function c26638543.con(e)
	local tp=e:GetHandler():GetControler()
	-- 获取玩家灵摆区域0号位置的卡
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取玩家灵摆区域1号位置的卡
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not tc1 or not tc2 then return false end
	return tc1:GetLeftScale()==tc2:GetRightScale()
end
-- 计算攻击力值为灵摆区域0号卡左刻度乘以100
function c26638543.val(e,c)
	-- 获取玩家灵摆区域0号位置的卡
	local tc=Duel.GetFieldCard(c:GetControler(),LOCATION_PZONE,0)
	return tc:GetLeftScale()*100
end
-- 判断是否为对方造成的战斗伤害且未攻击对方怪兽
function c26638543.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方造成的战斗伤害且未攻击对方怪兽
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置破坏效果的目标为双方灵摆区域的所有卡
function c26638543.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 设置操作信息为破坏效果，目标为所有灵摆区域的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将所有灵摆区域的卡破坏
function c26638543.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	if g:GetCount()>0 then
		-- 将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
