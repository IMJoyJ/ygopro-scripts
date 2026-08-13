--シュレツダー
-- 效果：
-- 从手卡把1只机械族怪兽送去墓地发动。送去墓地的怪兽的等级以下的对方场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
function c3603242.initial_effect(c)
	-- 从手卡把1只机械族怪兽送去墓地发动。送去墓地的怪兽的等级以下的对方场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3603242,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c3603242.descost)
	e1:SetTarget(c3603242.destg)
	e1:SetOperation(c3603242.desop)
	c:RegisterEffect(e1)
end
-- 检查手卡中是否存在1只机械族怪兽且可作为代价送去墓地，并且对方场上有表侧表示怪兽的等级不高于该怪兽，以确认发动条件是否满足。
function c3603242.cfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
		-- 确认对方场上有表侧表示怪兽可以作为效果对象，且其等级不大于作为代价送去墓地的机械族怪兽的等级。
		and Duel.IsExistingTarget(c3603242.dfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 判断怪兽是否为表侧表示且等级不超过指定的等级。
function c3603242.dfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
-- 代价处理：从手卡选择1只满足条件的机械族怪兽送去墓地，并将其等级记录在效果标签中，用于后续选择破坏对象。
function c3603242.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：确认存在1张可用于满足条件的手卡机械族怪兽，且存在可选的对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c3603242.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 向玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只满足机械族且可作为代价的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c3603242.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 将选择的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标选择处理：选择对方场上的1只表侧表示怪兽作为破坏对象，限制其等级不超过已送墓怪兽的等级，并设置破坏的操作信息。
function c3603242.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c3603242.dfilter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只表侧表示且等级不超过记录等级的怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c3603242.dfilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetLabel())
	-- 设置本次连锁的处理信息，声明将要破坏1只怪兽，以便其他卡牌响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若其仍然满足表侧表示、对方场上、与效果相关且等级不超过记录等级等条件，则将其破坏。
function c3603242.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时需要破坏的、之前选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) and tc:IsLevelBelow(e:GetLabel()) then
		-- 以效果破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
