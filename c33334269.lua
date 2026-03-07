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
-- 过滤函数，用于判断墓地中的卡是否满足条件：是DD怪兽或契约书卡，并且卡组中存在同名可送去墓地的卡。
function c33334269.tgfilter1(c,tp)
	return ((c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and not c:IsCode(33334269)) or c:IsSetCard(0xae))
		-- 检查卡组中是否存在与目标卡同名且可送去墓地的卡。
		and Duel.IsExistingMatchingCard(c33334269.tgfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤函数，用于判断卡组中的卡是否与指定卡号相同且可送去墓地。
function c33334269.tgfilter2(c,cd)
	return c:IsCode(cd) and c:IsAbleToGrave()
end
-- 设置效果目标，选择满足条件的墓地中的卡作为对象，并设置操作信息。
function c33334269.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsCode(e:GetLabel()) end
	-- 检查是否满足发动条件：存在满足条件的墓地目标卡。
	if chk==0 then return Duel.IsExistingTarget(c33334269.tgfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地中的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c33334269.tgfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置操作信息，表示将从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择卡组中与目标卡同名的卡并将其送去墓地。
function c33334269.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择卡组中与目标卡同名的卡。
		local g=Duel.SelectMatchingCard(tp,c33334269.tgfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选中的卡从卡组送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断除外区中的卡是否满足条件：是DD怪兽或契约书卡。
function c33334269.rtgfilter(c)
	return c:IsFaceup() and ((c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and not c:IsCode(33334269)) or c:IsSetCard(0xae))
end
-- 设置效果目标，选择满足条件的除外区中的卡作为对象，并设置操作信息。
function c33334269.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c33334269.rtgfilter(chkc) end
	-- 检查是否满足发动条件：存在满足条件的除外区目标卡。
	if chk==0 then return Duel.IsExistingTarget(c33334269.rtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的除外区中的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c33334269.rtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将卡送回墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理函数，将选中的除外区中的卡送回墓地。
function c33334269.rtgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的卡从除外区送回墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
