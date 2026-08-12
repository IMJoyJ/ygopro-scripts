--No.81 超弩級砲塔列車スペリオル・ドーラ
-- 效果：
-- 10星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
function c49032236.initial_effect(c)
	-- 为卡片添加等级为10、需要2个超量素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49032236,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c49032236.cost)
	e1:SetTarget(c49032236.target)
	e1:SetOperation(c49032236.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡的编号为81
aux.xyz_number[49032236]=81
-- 费用处理：检查并移除1个超量素材作为发动代价
function c49032236.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标选择：选择1只场上的表侧表示怪兽作为效果对象
function c49032236.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使目标怪兽在回合结束前免疫除自身外的效果影响
function c49032236.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c49032236.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果过滤函数：判断效果来源是否为施加效果的怪兽本身
function c49032236.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
