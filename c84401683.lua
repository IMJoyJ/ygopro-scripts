--ゴルゴニック・ガーディアン
-- 效果：
-- 岩石族3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。直到回合结束时，选择的怪兽的攻击力变成0，那个效果无效。这个效果在对方回合也能发动。此外，1回合1次，选择场上1只攻击力是0的怪兽才能发动。选择的怪兽破坏。
function c84401683.initial_effect(c)
	-- 设置XYZ召唤条件为岩石族3星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。直到回合结束时，选择的怪兽的攻击力变成0，那个效果无效。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84401683,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为伤害步骤中伤害计算前以外的时点
	e1:SetCondition(aux.dscon)
	e1:SetCost(c84401683.negcost)
	e1:SetTarget(c84401683.negtg)
	e1:SetOperation(c84401683.negop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，选择场上1只攻击力是0的怪兽才能发动。选择的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84401683,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c84401683.destg)
	e2:SetOperation(c84401683.desop)
	c:RegisterEffect(e2)
end
-- 效果1的发动代价：取除这张卡的1个超量素材
function c84401683.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤对方场上表侧表示且攻击力大于0的怪兽
function c84401683.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果1的发动目标：选择对方场上1只表侧表示且攻击力大于0的怪兽
function c84401683.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c84401683.filter(chkc) end
	-- 检查对方场上是否存在满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c84401683.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示且攻击力大于0的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84401683.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为使1张卡的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果1的效果处理：使选择的怪兽攻击力变成0，效果无效
function c84401683.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 使与该怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 选择的怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那个效果无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 过滤场上表侧表示且攻击力为0的怪兽
function c84401683.desfilter(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 效果2的发动目标：选择场上1只表侧表示且攻击力为0的怪兽
function c84401683.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c84401683.desfilter(chkc) end
	-- 检查场上是否存在满足条件的攻击力为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(c84401683.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示且攻击力为0的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84401683.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为破坏该怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果2的效果处理：破坏选择的怪兽
function c84401683.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
