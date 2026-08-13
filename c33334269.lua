--DDゴースト
-- 效果：
-- ①：这张卡被送去墓地的场合，以除「DD 幽灵」外的自己墓地1只「DD」怪兽或1张「契约书」卡为对象才能发动。那1张同名卡从卡组送去墓地。
-- ②：这张卡被除外的场合，以除「DD 幽灵」外的自己的除外状态的1只「DD」怪兽或1张「契约书」卡为对象才能发动。那张卡回到墓地。
function c33334269.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，以除「DD 幽灵」外的自己墓地1只「DD」怪兽或1张「契约书」卡为对象才能发动。那1张同名卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33334269,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c33334269.tgtg)
	e1:SetOperation(c33334269.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以除「DD 幽灵」外的自己的除外状态的1只「DD」怪兽或1张「契约书」卡为对象才能发动。那张卡回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33334269,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c33334269.rtgtg)
	e2:SetOperation(c33334269.rtgop)
	c:RegisterEffect(e2)
end
-- 墓地对象候选过滤：满足「DD」怪兽（不含本卡）或「契约书」卡，且确认卡组中存在同名卡可被送去墓地。
function c33334269.tgfilter1(c,tp)
	return ((c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and not c:IsCode(33334269)) or c:IsSetCard(0xae))
		-- 确认卡组中存在与对象候选同名的卡，且该同名卡能够被送去墓地。
		and Duel.IsExistingMatchingCard(c33334269.tgfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 卡组内同名卡过滤：卡名与所选对象的卡号一致，并且该卡可以被送去墓地。
function c33334269.tgfilter2(c,cd)
	return c:IsCode(cd) and c:IsAbleToGrave()
end
-- 第一个效果的发动条件与对象选择：从自己墓地选择1张符合条件的「DD」怪兽或「契约书」卡（不含本卡）作为对象，记录其卡号，并设定将卡组1张同名卡送去墓地的操作信息。
function c33334269.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsCode(e:GetLabel()) end
	-- 发动条件检查：自己墓地存在至少1张符合条件的对象候选卡（且其同名卡在卡组中可送墓）。
	if chk==0 then return Duel.IsExistingTarget(c33334269.tgfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家发出选择效果对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1张符合条件的卡作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c33334269.tgfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设定操作信息：效果处理时从卡组将1张卡送去墓地（具体卡在效果处理时确定，因此目标暂为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 第一个效果的处理：若对象仍与效果关联，则从卡组选择1张与对象同名的卡送去墓地。
function c33334269.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 弹出从卡组选择要送去墓地的卡的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张与对象同名且能够送去墓地的卡。
		local g=Duel.SelectMatchingCard(tp,c33334269.tgfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选择的卡以效果原因送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 除外区对象候选过滤：表侧表示，且满足「DD」怪兽（不含本卡）或「契约书」卡。
function c33334269.rtgfilter(c)
	return c:IsFaceup() and ((c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and not c:IsCode(33334269)) or c:IsSetCard(0xae))
end
-- 第二个效果的发动条件与对象选择：从自己的除外状态选择1张符合条件的「DD」怪兽或「契约书」卡（不含本卡）作为对象，并设定将其送去墓地的操作信息。
function c33334269.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c33334269.rtgfilter(chkc) end
	-- 发动条件检查：自己的除外状态存在至少1张符合条件的表侧表示对象候选卡。
	if chk==0 then return Duel.IsExistingTarget(c33334269.rtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家发出选择效果对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己的除外状态选择1张符合条件的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c33334269.rtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设定操作信息：将所选择的对象卡送去墓地（对象确定，因此targets传入已选对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 第二个效果的处理：若对象仍与效果关联，则将对象卡以效果原因与回到墓地原因送去墓地。
function c33334269.rtgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因+回到墓地原因送去墓地，对应“那张卡回到墓地”的规则处理。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
