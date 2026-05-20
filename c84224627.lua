--キャット・シャーク
-- 效果：
-- 2星怪兽×2
-- ①：这张卡持有水属性怪兽作为超量素材的场合，这张卡不会被战斗破坏。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只4阶以下的超量怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍。这个效果在对方回合也能发动。
function c84224627.initial_effect(c)
	-- 添加XYZ召唤手续：2星怪兽×2
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡持有水属性怪兽作为超量素材的场合，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c84224627.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只4阶以下的超量怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84224627,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	-- 设置效果的发动条件：在伤害步骤中，伤害计算后不能发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c84224627.cost)
	e2:SetTarget(c84224627.target)
	e2:SetOperation(c84224627.operation)
	c:RegisterEffect(e2)
end
-- 判定自身是否持有水属性怪兽作为超量素材的辅助条件函数
function c84224627.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
end
-- 效果发动的代价：取除这张卡的1个超量素材
function c84224627.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤自己场上表侧表示的4阶以下的超量怪兽的辅助过滤函数
function c84224627.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRankBelow(4)
end
-- 效果发动的目标选择：选择自己场上1只表侧表示的4阶以下的超量怪兽
function c84224627.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c84224627.filter(chkc) end
	-- 在发动准备阶段，检查自己场上是否存在符合条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c84224627.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择并锁定1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c84224627.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使目标怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍
function c84224627.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetBaseAttack()*2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e2)
	end
end
