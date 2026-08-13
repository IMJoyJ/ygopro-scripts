--六武衆の影－紫炎
-- 效果：
-- 4星「六武众」怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只攻击力未满2000的「六武众」怪兽为对象才能发动。那只怪兽的原本攻击力直到回合结束时变成2000。这个效果在对方回合也能发动。
function c1828513.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只等级4的「六武众」怪兽作为超量素材进行XYZ召唤。
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
-- 发动代价：检查并取除这张卡的1个超量素材作为COST。
function c1828513.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 取对象过滤条件：表侧表示、属于「六武众」、当前攻击力未满2000的怪兽。
function c1828513.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:GetAttack()<2000
end
-- 取对象处理：选择自己场上1只满足条件的表侧表示「六武众」怪兽作为效果对象。
function c1828513.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1828513.filter(chkc) end
	-- 效果发动前检查自己场上是否存在至少1只满足条件的「六武众」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c1828513.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的表侧表示「六武众」怪兽，并将其设置为效果对象。
	Duel.SelectTarget(tp,c1828513.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果相关且满足条件，则对其赋予直到回合结束时原本攻击力变为2000的效果。
function c1828513.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c1828513.filter(tc) then
		-- 那只怪兽的原本攻击力直到回合结束时变成2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
