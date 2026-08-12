--ブラック・ソニック
-- 效果：
-- 自己场上的怪兽只有「黑羽」怪兽3只的场合，这张卡的发动从手卡也能用。
-- ①：对方怪兽向自己场上的「黑羽」怪兽攻击宣言时才能发动。对方场上的表侧攻击表示怪兽全部除外。
function c72930878.initial_effect(c)
	-- ①：对方怪兽向自己场上的「黑羽」怪兽攻击宣言时才能发动。对方场上的表侧攻击表示怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c72930878.condition)
	e1:SetTarget(c72930878.target)
	e1:SetOperation(c72930878.activate)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽只有「黑羽」怪兽3只的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72930878,0))  --"适用「黑翼音速」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c72930878.handcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且卡名含有「黑羽」的怪兽
function c72930878.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 手牌发动条件：自己场上的怪兽数量为3，且全部是「黑羽」怪兽
function c72930878.handcon(e)
	-- 获取自己场上怪兽区的所有卡
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	return g:GetCount()==3 and g:IsExists(c72930878.cfilter,3,nil)
end
-- 发动条件：对方怪兽向自己场上表侧表示的「黑羽」怪兽发动攻击宣言时
function c72930878.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对象（被攻击的怪兽）
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(0x33)
end
-- 过滤条件：表侧攻击表示且可以被除外的怪兽
function c72930878.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToRemove()
end
-- 效果发动目标：检查对方场上是否存在表侧攻击表示怪兽，并设置除外操作信息
function c72930878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方场上是否存在至少1只表侧攻击表示且可以被除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72930878.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧攻击表示且可以被除外的怪兽
	local g=Duel.GetMatchingGroup(c72930878.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：除外对方场上所有符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：将对方场上所有表侧攻击表示的怪兽除外
function c72930878.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧攻击表示且可以被除外的怪兽
	local g=Duel.GetMatchingGroup(c72930878.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽以表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
