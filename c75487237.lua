--ミドル・シールド・ガードナー
-- 效果：
-- 这张卡1个回合1次可以变成里侧守备表示。以里侧表示的这只怪兽为对象的魔法卡的发动无效。那个时候，这张卡变成表侧守备表示。
function c75487237.initial_effect(c)
	-- 这张卡1个回合1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75487237,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c75487237.target)
	e1:SetOperation(c75487237.operation)
	c:RegisterEffect(e1)
	-- 以里侧表示的这只怪兽为对象的魔法卡的发动无效。那个时候，这张卡变成表侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c75487237.negcon)
	e2:SetOperation(c75487237.negop)
	c:RegisterEffect(e2)
end
-- 确认自身是否可以转为里侧守备表示且本回合未发动过该效果，注册一回合一次的Flag并设置改变表示形式的操作信息
function c75487237.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(75487237)==0 end
	c:RegisterFlagEffect(75487237,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息为改变1张卡（自身）的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若自身仍在场上且为表侧表示，则将其转为里侧守备表示
function c75487237.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 确认触发效果的连锁是否为以里侧表示的自身为唯一对象的魔法卡的发动
function c75487237.negcon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取当前处理的连锁的对象卡片组
		local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		return tg:GetCount()==1 and tg:GetFirst()==e:GetHandler() and e:GetHandler():IsFacedown()
	else
		return false
	end
end
-- 效果处理时，使该魔法卡的发动无效，并把自身转为表侧守备表示
function c75487237.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身改变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
