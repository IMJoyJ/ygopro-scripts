--白闘気海豚
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
-- ②：这张卡被对方破坏送去墓地的场合，把这张卡以外的自己墓地1只水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
function c78229193.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78229193,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c78229193.atktg)
	e1:SetOperation(c78229193.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合，把这张卡以外的自己墓地1只水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78229193,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c78229193.condition)
	e3:SetCost(c78229193.cost)
	e3:SetTarget(c78229193.target)
	e3:SetOperation(c78229193.operation)
	c:RegisterEffect(e3)
end
c78229193.treat_itself_tuner=true
-- 效果①的对象选择函数：判断并选择对方场上1只表侧表示怪兽作为对象
function c78229193.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理函数：将作为对象的怪兽的攻击力直到回合结束时变成原本攻击力的一半
function c78229193.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetBaseAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件函数：检查这张卡是否被对方通过战斗或效果破坏并送去墓地
function c78229193.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤条件：自己墓地中除这张卡以外的水属性怪兽，且可以作为除外Cost
function c78229193.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价函数：从自己墓地将这张卡以外的1只水属性怪兽除外
function c78229193.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除这张卡以外的、可作为发动代价除外的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78229193.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中1只满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c78229193.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的怪兽表侧表示除外，作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备函数：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c78229193.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息，表明此效果包含将自身特殊召唤的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数：将自身特殊召唤，并使其当作调整使用
function c78229193.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并尝试以表侧表示特殊召唤自身（分步处理）
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡当作调整使用特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
