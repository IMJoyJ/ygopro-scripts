--No.81 超弩級砲塔列車スペリオル・ドーラ
-- 效果：
-- 10星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
function c49032236.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：等级10的怪兽2只作为超量素材。
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
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
-- 登记这张卡的No.编号为81，用于No.相关判定。
aux.xyz_number[49032236]=81
-- 代价函数：发动前检查是否有可去除的超量素材，确认后实际取除这张卡1个超量素材作为代价。
function c49032236.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标函数：发动时选择场上1只表侧表示怪兽作为效果对象。
function c49032236.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示怪兽可以作为取对象的目标。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数：对对象怪兽赋予直到回合结束时不受自身以外的卡的效果影响的免疫效果。
function c49032236.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的1只对象怪兽。
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
-- 免疫判定函数：只要发动效果的卡不是被免疫效果所附属的怪兽自身，则该效果对其无效（即除了自身以外的卡的效果）。
function c49032236.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
