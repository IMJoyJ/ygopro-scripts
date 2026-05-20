--インフェルノイド・デカトロン
-- 效果：
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「狱火机十进管」以外的1只「狱火机」怪兽送去墓地。这张卡等级上升那只怪兽的等级数值，得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c58446973.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「狱火机十进管」以外的1只「狱火机」怪兽送去墓地。这张卡等级上升那只怪兽的等级数值，得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(c58446973.target)
	e1:SetOperation(c58446973.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「狱火机十进管」以外的「狱火机」怪兽
function c58446973.filter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and not c:IsCode(58446973) and c:IsAbleToGrave()
end
-- 效果发动的可行性检测，确认自身在场且卡组中存在符合条件的怪兽
function c58446973.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查卡组中是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c58446973.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑：将卡组中1只「狱火机」怪兽送去墓地，并使自身等级上升该怪兽的等级，且获得其原本卡名和效果
function c58446973.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c58446973.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 确认成功将选中的怪兽送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetCode()
		-- 这张卡等级上升那只怪兽的等级数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(code)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
	end
end
