--零鳥姫リオート・ハルピュイア
-- 效果：
-- 鸟兽族5星怪兽×2
-- 把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力变成0。
function c13183454.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足鸟兽族条件的怪兽作为素材进行召唤，等级为5，最少需要2个素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),5,2)
	c:EnableReviveLimit()
	-- 把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13183454,0))  --"攻击变成0"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c13183454.cost)
	e1:SetTarget(c13183454.target)
	e1:SetOperation(c13183454.operation)
	c:RegisterEffect(e1)
end
-- 费用函数，检查是否能移除1个超量素材作为发动代价
function c13183454.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选表侧表示且攻击力大于0的怪兽
function c13183454.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 目标选择函数，用于选择对方场上的表侧表示怪兽
function c13183454.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c13183454.filter(chkc) end
	-- 判断是否有满足条件的目标怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c13183454.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择对方场上表侧表示的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c13183454.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时的处理函数
function c13183454.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 选择的怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
