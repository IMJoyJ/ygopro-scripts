--ヘル・ブラスト
-- 效果：
-- 自己场上表侧表示存在的怪兽破坏送去墓地时发动。场上表侧表示攻击力最低的1只怪兽破坏，双方受到那个攻击力一半的数值的伤害。
function c18271561.initial_effect(c)
	-- 效果原文内容：自己场上表侧表示存在的怪兽破坏送去墓地时发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c18271561.condition)
	e1:SetTarget(c18271561.target)
	e1:SetOperation(c18271561.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查怪兽是否从场上破坏送去墓地
function c18271561.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
end
-- 效果作用：满足条件的怪兽数量大于等于1
function c18271561.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18271561.filter,1,nil,tp)
end
-- 效果作用：设置连锁处理信息，确定破坏和伤害效果
function c18271561.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local dg=g:GetMinGroup(Card.GetAttack)
	-- 效果作用：设置破坏效果的目标为攻击力最低的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 效果作用：设置伤害效果的目标为双方玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 效果原文内容：场上表侧表示攻击力最低的1只怪兽破坏，双方受到那个攻击力一半的数值的伤害。
function c18271561.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local dg=g:GetMinGroup(Card.GetAttack)
	if dg:GetCount()>1 then
		-- 效果作用：提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		dg=dg:Select(tp,1,1,nil)
	end
	local atk=math.floor(dg:GetFirst():GetAttack()/2)
	-- 效果作用：执行破坏操作并判断是否成功
	if Duel.Destroy(dg,REASON_EFFECT)>0 then
		-- 效果作用：给发动者造成攻击力一半的伤害
		Duel.Damage(tp,atk,REASON_EFFECT,true)
		-- 效果作用：给对方玩家造成攻击力一半的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT,true)
		-- 效果作用：触发伤害处理完成的时点
		Duel.RDComplete()
	end
end
