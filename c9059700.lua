--インフェルニティ・バリア
-- 效果：
-- 自己场上有名字带有「永火」的怪兽表侧攻击表示存在，自己手卡是0张的场合才能发动。对方发动的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c9059700.initial_effect(c)
	-- 自己场上有名字带有「永火」的怪兽表侧攻击表示存在，自己手卡是0张的场合才能发动。对方发动的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c9059700.condition)
	e1:SetTarget(c9059700.target)
	e1:SetOperation(c9059700.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧攻击表示且卡名含有「永火」的怪兽
function c9059700.cfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0xb)
end
-- 发动条件：对方发动效果，且自己场上有表侧攻击表示的「永火」怪兽存在，且自己手卡为0张
function c9059700.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动者是自己，或者自己场上不存在表侧攻击表示的「永火」怪兽，则不能发动
	if ep==tp or not Duel.IsExistingMatchingCard(c9059700.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 或者自己手卡数量不为0，则不能发动
		or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 then return false end
	-- 返回该连锁是否可被无效，且该效果是否为怪兽效果、魔法卡的发动或陷阱卡的发动
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 靶向/操作信息设置：设置无效与破坏的操作信息
function c9059700.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若该卡可被破坏且与该效果有关联，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c9059700.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
