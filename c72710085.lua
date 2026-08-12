--星邪の神喰
-- 效果：
-- 只让自己墓地的怪兽1只被从游戏中除外的场合，可以把和除外的那只怪兽不同属性的1只怪兽从卡组送去墓地。「星邪的神食」的效果1回合只能使用1次。
function c72710085.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只让自己墓地的怪兽1只被从游戏中除外的场合，可以把和除外的那只怪兽不同属性的1只怪兽从卡组送去墓地。「星邪的神食」的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72710085,0))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,72710085)
	e2:SetCondition(c72710085.tgcon)
	e2:SetTarget(c72710085.tgtg)
	e2:SetOperation(c72710085.tgop)
	c:RegisterEffect(e2)
end
-- 判断触发条件：是否仅有自己墓地的1只怪兽被除外
function c72710085.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsPreviousLocation(LOCATION_GRAVE) and tc:IsControler(tp) and tc:IsType(TYPE_MONSTER)
end
-- 过滤卡组中与指定属性不同、且能送去墓地的怪兽
function c72710085.filter(c,att)
	return not c:IsAttribute(att) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动的目标选择与检测，记录除外怪兽的属性并设置送墓的操作信息
function c72710085.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查卡组中是否存在与被除外怪兽不同属性且能送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72710085.filter,tp,LOCATION_DECK,0,1,nil,eg:GetFirst():GetAttribute()) end
	e:SetLabel(eg:GetFirst():GetAttribute())
	-- 设置效果处理的操作信息为：将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1张与被除外怪兽不同属性的怪兽送去墓地
function c72710085.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张与被除外怪兽不同属性的怪兽
	local g=Duel.SelectMatchingCard(tp,c72710085.filter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
