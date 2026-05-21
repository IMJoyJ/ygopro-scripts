--星読みの魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己的灵摆怪兽进行战斗的场合，对方直到伤害步骤结束时魔法卡不能发动。
-- ②：另一边的自己的灵摆区域没有「魔术师」卡或者「异色眼」卡存在的场合，这张卡的灵摆刻度变成4。
-- 【怪兽效果】
-- ①：1回合1次，只让自己场上的灵摆怪兽1只因对方的效果回到自己手卡时才能发动。那1只同名怪兽从手卡特殊召唤。
function c94415058.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己的灵摆怪兽进行战斗的场合，对方直到伤害步骤结束时魔法卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c94415058.aclimit)
	e2:SetCondition(c94415058.actcon)
	c:RegisterEffect(e2)
	-- ②：另一边的自己的灵摆区域没有「魔术师」卡或者「异色眼」卡存在的场合，这张卡的灵摆刻度变成4。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_LSCALE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(c94415058.sccon)
	e4:SetValue(4)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e5)
	-- ①：1回合1次，只让自己场上的灵摆怪兽1只因对方的效果回到自己手卡时才能发动。那1只同名怪兽从手卡特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(94415058,0))  --"特殊召唤"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c94415058.spcon)
	e6:SetTarget(c94415058.sptg)
	e6:SetOperation(c94415058.spop)
	c:RegisterEffect(e6)
end
-- 检查是否为自己的灵摆怪兽进行战斗的场合
function c94415058.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	if not tc then return false end
	-- 如果攻击怪兽是对方的，则将目标怪兽切换为被攻击的怪兽（即己方的怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsControler(tp) and tc:IsType(TYPE_PENDULUM)
end
-- 限制发动卡片的类型为魔法卡的发动
function c94415058.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤属于「魔术师」或「异色眼」系列卡片的过滤函数
function c94415058.scfilter(c)
	return c:IsSetCard(0x98,0x99)
end
-- 检查另一边的灵摆区域是否存在「魔术师」卡或「异色眼」卡
function c94415058.sccon(e)
	-- 检查除自身外，自己的灵摆区域是否存在不满足「魔术师」或「异色眼」条件的卡（即没有「魔术师」卡或「异色眼」卡存在）
	return not Duel.IsExistingMatchingCard(c94415058.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
-- 检查是否满足“只让自己场上的1只表侧表示灵摆怪兽因对方的效果回到手卡”的发动条件，并记录该怪兽的卡号
function c94415058.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if eg:GetCount()==1 and rp==1-tp and tc:IsReason(REASON_EFFECT)
		and tc:IsPreviousControler(tp) and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_FACEUP)
		and tc:IsType(TYPE_PENDULUM) and tc:IsControler(tp) then
		e:SetLabel(tc:GetCode())
		return true
	end
	return false
end
-- 过滤手卡中与回到手卡的怪兽同名且可以特殊召唤的怪兽
function c94415058.filter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检查，确认己方主要怪兽区域有空位且手卡有同名怪兽可特殊召唤
function c94415058.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查己方场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1张满足特殊召唤条件的同名怪兽
		and Duel.IsExistingMatchingCard(c94415058.filter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数，从手卡选择同名怪兽特殊召唤到场上
function c94415058.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若己方场上已无可用怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1张满足条件的同名怪兽
	local g=Duel.SelectMatchingCard(tp,c94415058.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
