--守護竜アンドレイク
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组的特殊召唤成功的场合才能发动。这张卡的原本的攻击力·守备力直到下个回合的结束时变成2倍。
-- ②：这张卡从墓地的特殊召唤成功的场合或者除外的这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c6990577.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c6990577.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡从手卡·卡组的特殊召唤成功的场合才能发动。这张卡的原本的攻击力·守备力直到下个回合的结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6990577,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,6990577)
	e2:SetCondition(c6990577.atkcon)
	e2:SetOperation(c6990577.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡从墓地的特殊召唤成功的场合或者除外的这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6990577,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,6990578)
	e3:SetCondition(c6990577.descon)
	e3:SetTarget(c6990577.destg)
	e3:SetOperation(c6990577.desop)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤条件，判定是否为通过卡的效果（发动效果的处理）进行的特殊召唤
function c6990577.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 判定这张卡特殊召唤前的原本位置是否为手卡或卡组
function c6990577.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 将这张卡的原本攻击力·守备力直到下个回合的结束时变成2倍
function c6990577.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local batk=c:GetBaseAttack()
		local bdef=c:GetBaseDefense()
		-- 这张卡的原本的攻击力直到下个回合的结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(batk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(bdef*2)
		c:RegisterEffect(e2)
	end
end
-- 判定这张卡特殊召唤前的原本位置是否为墓地或除外区
function c6990577.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 破坏效果的靶向选择，确认并选择对方场上1只怪兽作为对象，并设置破坏的操作信息
function c6990577.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动阶段，检查对方场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 在界面上提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向系统注册当前连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行，获取对象怪兽并将其因效果破坏
function c6990577.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因卡的效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
