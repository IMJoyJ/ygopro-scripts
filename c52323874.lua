--RR－デビル・イーグル
-- 效果：
-- 3星「急袭猛禽」怪兽×2
-- 「急袭猛禽-恶魔雕」的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上1只特殊召唤的表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c52323874.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足「急袭猛禽」卡组条件的3星怪兽作为素材进行2次叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xba),3,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以对方场上1只特殊召唤的表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52323874,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52323874)
	e1:SetCost(c52323874.cost)
	e1:SetTarget(c52323874.target)
	e1:SetOperation(c52323874.operation)
	c:RegisterEffect(e1)
end
-- 费用处理函数，检查并移除自身1个超量素材作为发动代价
function c52323874.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标过滤函数，筛选对方场上的表侧表示、原本攻击力大于0且为特殊召唤的怪兽
function c52323874.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果目标选择函数，选择符合条件的对方场上表侧表示怪兽作为攻击对象，并设置伤害计算信息
function c52323874.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c52323874.filter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c52323874.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个符合条件的对方场上的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c52323874.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	-- 设置连锁操作信息，指定将对对方造成相当于目标怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果处理函数，对选定的目标怪兽造成其原本攻击力数值的伤害
function c52323874.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 对对方玩家造成相当于目标怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
