--バーバリアン・ハウリング
-- 效果：
-- ①：自己场上的战士族怪兽成为对方怪兽的效果的对象时或者被选择作为对方怪兽的攻击对象时，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害，那只怪兽回到持有者手卡。
function c78621186.initial_effect(c)
	-- ①：自己场上的战士族怪兽被选择作为对方怪兽的攻击对象时，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害，那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78621186,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c78621186.condition1)
	e1:SetTarget(c78621186.target)
	e1:SetOperation(c78621186.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCondition(c78621186.condition2)
	c:RegisterEffect(e2)
end
-- 判定被选择为攻击对象的怪兽是否为自己场上表侧表示的战士族怪兽
function c78621186.condition1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_WARRIOR)
end
-- 过滤条件：自己场上表侧表示的战士族怪兽
function c78621186.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_WARRIOR)
end
-- 判定是否因对方怪兽的效果，使自己场上的表侧表示战士族怪兽成为对象
function c78621186.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and eg:IsExists(c78621186.cfilter,1,nil,tp)
end
-- 效果发动时的对象选择与操作信息注册
function c78621186.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 判定对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置给与对方伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	-- 设置将目标怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：给与对方目标怪兽原本攻击力数值的伤害，并将其送回持有者手牌
function c78621186.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		-- 给与对方该怪兽原本攻击力数值的伤害，若未成功造成伤害则不处理后续效果
		if Duel.Damage(1-tp,dam,REASON_EFFECT)==0 then return end
		-- 将目标怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
