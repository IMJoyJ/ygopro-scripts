--RR－ブースター・ストリクス
-- 效果：
-- ①：自己的「急袭猛禽」怪兽被选择作为对方怪兽的攻击对象时，把这张卡从手卡除外才能发动。那只攻击怪兽破坏。
function c73977033.initial_effect(c)
	-- ①：自己的「急袭猛禽」怪兽被选择作为对方怪兽的攻击对象时，把这张卡从手卡除外才能发动。那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c73977033.condition)
	e1:SetCost(c73977033.cost)
	e1:SetTarget(c73977033.target)
	e1:SetOperation(c73977033.operation)
	c:RegisterEffect(e1)
end
-- 检查被选择作为攻击对象的怪兽是否为自己场上表侧表示的「急袭猛禽」怪兽
function c73977033.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=eg:GetFirst()
	return at:IsFaceup() and at:IsControler(tp) and at:IsSetCard(0xba)
end
-- 作为发动的代价，将手卡的这张卡除外
function c73977033.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡作为代价表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 将攻击怪兽作为效果对象，并设置破坏该怪兽的操作信息
function c73977033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	-- 将攻击怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(tg)
	-- 设置破坏分类的操作信息，确定要破坏的卡为该攻击怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理时，若对象怪兽仍满足条件，则将其破坏
function c73977033.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为效果对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 因效果将该攻击怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
