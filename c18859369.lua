--カオス・グレファー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
-- ②：从手卡丢弃1只光属性或者暗属性的怪兽才能发动。和丢弃的怪兽属性不同的1只光·暗属性怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤。
function c18859369.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1只光属性或者暗属性的怪兽才能发动。和丢弃的怪兽属性不同的1只光·暗属性怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18859369,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,18859369)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18859369.sgcost)
	e2:SetTarget(c18859369.sgtg)
	e2:SetOperation(c18859369.sgop)
	c:RegisterEffect(e2)
end
-- 设置标记以确认是否满足发动条件
function c18859369.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤手牌中可丢弃的光或暗属性怪兽，并确保卡组中存在与丢弃怪兽属性不同的光或暗属性怪兽
function c18859369.tgfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsDiscardable()
		-- 检查卡组中是否存在与丢弃怪兽属性不同的光或暗属性怪兽
		and Duel.IsExistingMatchingCard(c18859369.tgfilter2,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 过滤卡组中可送去墓地的光或暗属性怪兽，且属性与指定属性不同
function c18859369.tgfilter2(c,attr)
	return c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT)
		and not c:IsAttribute(attr)
end
-- 检测是否满足发动条件，若满足则选择手牌中的一只光或暗属性怪兽丢弃，并准备将卡组中一只属性不同的光或暗属性怪兽送去墓地
function c18859369.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在满足条件的光或暗属性怪兽
		return Duel.IsExistingMatchingCard(c18859369.tgfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的手牌并将其丢弃
	local tc=Duel.SelectMatchingCard(tp,c18859369.tgfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetAttribute())
	-- 将选中的手牌丢入墓地
	Duel.SendtoGrave(tc,REASON_DISCARD+REASON_COST)
	-- 设置操作信息，表示将有1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 选择卡组中一只属性与丢弃怪兽不同的光或暗属性怪兽并将其送去墓地，若成功则设置效果禁止特殊召唤
function c18859369.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一只属性与丢弃怪兽不同的光或暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c18859369.tgfilter2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	local tc=g:GetFirst()
	-- 判断选中的卡是否成功送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 创建并注册一个永续效果，禁止在本回合特殊召唤与送去墓地的怪兽同名的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetCode())
		e1:SetTarget(c18859369.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 设置效果的目标为与指定卡号相同的怪兽
function c18859369.splimit(e,c)
	return c:IsCode(e:GetLabel())
end
