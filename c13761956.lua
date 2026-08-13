--フレムベル・ベビー
-- 效果：
-- 自己的主要阶段时，把这张卡从手卡送去墓地发动。自己场上表侧表示存在的1只炎属性怪兽的攻击力上升400。
function c13761956.initial_effect(c)
	-- 自己的主要阶段时，把这张卡从手卡送去墓地发动。自己场上表侧表示存在的1只炎属性怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13761956,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c13761956.atcost)
	e1:SetTarget(c13761956.attg)
	e1:SetOperation(c13761956.atop)
	c:RegisterEffect(e1)
end
-- 代价处理：在发动确认阶段检查这张卡是否可作为代价从手卡送去墓地；确认后执行将其送去墓地的代价操作。
function c13761956.atcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行发动代价：将这张卡以代价（REASON_COST）从手卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选条件：卡片须为表侧表示且属性为炎属性。
function c13761956.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 取对象处理：确认对象必须是己方场上表侧表示且炎属性的怪兽；若无合法目标则不可发动；随后提示玩家从符合条件的怪兽中选择1只作为效果对象。
function c13761956.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13761956.filter(chkc) end
	-- 检查己方场上是否存在至少1只满足筛选条件的表侧炎属性怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c13761956.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择表侧表示怪兽的提示信息（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从己方场上表侧表示的炎属性怪兽中选择1只作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c13761956.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍为表侧表示且与效果相关联，则赋予其攻击力上升400的持续效果，并在标准重置条件下失效。
function c13761956.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 自己场上表侧表示存在的1只炎属性怪兽的攻击力上升400。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
