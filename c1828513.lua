--六武衆の影－紫炎
-- 效果：
-- 4星「六武众」怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只攻击力未满2000的「六武众」怪兽为对象才能发动。那只怪兽的原本攻击力直到回合结束时变成2000。这个效果在对方回合也能发动。
function c1828513.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足「六武众」字段且等级为4的怪兽作为素材，需要2只怪兽进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x103d),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只攻击力未满2000的「六武众」怪兽为对象才能发动。那只怪兽的原本攻击力直到回合结束时变成2000。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(1828513,0))  --"攻击变化"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCost(c1828513.cost)
	e1:SetTarget(c1828513.target)
	e1:SetOperation(c1828513.operation)
	c:RegisterEffect(e1)
end
-- 费用处理函数，检查并移除自身1个超量素材作为发动代价
function c1828513.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选场上表侧表示的「六武众」怪兽且攻击力未满2000的怪兽
function c1828513.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:GetAttack()<2000
end
-- 效果目标选择函数，选择满足条件的场上1只「六武众」怪兽作为对象
function c1828513.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1828513.filter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c1828513.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上1只「六武众」怪兽作为对象
	Duel.SelectTarget(tp,c1828513.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数，为选定目标怪兽设置攻击力变为2000
function c1828513.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c1828513.filter(tc) then
		-- 将攻击力设置为2000的效果，直到回合结束时生效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
