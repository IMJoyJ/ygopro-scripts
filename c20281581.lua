--EMモモンカーペット
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域没有卡存在的场合这张卡破坏。
-- ②：只要这张卡在灵摆区域存在，自己受到的战斗伤害变成一半。
-- 【怪兽效果】
-- ①：这张卡反转的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡特殊召唤成功的场合才能发动。这张卡变成里侧守备表示。
function c20281581.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c20281581.descon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在灵摆区域存在，自己受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	-- ①：这张卡反转的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20281581,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c20281581.target)
	e3:SetOperation(c20281581.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤成功的场合才能发动。这张卡变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20281581,2))
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c20281581.postg)
	e4:SetOperation(c20281581.posop)
	c:RegisterEffect(e4)
end
-- 判断另一边的自己的灵摆区域是否没有卡存在
function c20281581.descon(e)
	-- 另一边的自己的灵摆区域没有卡存在时，该卡破坏
	return not Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数，用于判断目标卡是否为里侧表示
function c20281581.filter(c)
	return c:IsFacedown()
end
-- 设置反转效果的发动条件和目标选择逻辑
function c20281581.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c20281581.filter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c20281581.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张里侧表示的卡作为目标
	local g=Duel.SelectTarget(tp,c20281581.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行反转效果的破坏操作
function c20281581.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 设置特殊召唤成功后的效果发动条件
function c20281581.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() end
	-- 设置效果处理信息，确定要改变表示形式的卡
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行特殊召唤成功后的表示形式改变操作
function c20281581.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
