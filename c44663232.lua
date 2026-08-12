--異怪の妖精 エルフォビア
-- 效果：
-- 1回合1次，把手卡1只风属性怪兽给对方观看才能发动。直到下次的对方的主要阶段1结束时，双方玩家不能把比给人观看的怪兽等级高的怪兽的效果发动。
function c44663232.initial_effect(c)
	-- 1回合1次，把手卡1只风属性怪兽给对方观看才能发动。直到下次的对方的主要阶段1结束时，双方玩家不能把比给人观看的怪兽等级高的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44663232,0))  --"效果抑制"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c44663232.cost)
	e2:SetOperation(c44663232.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查手卡中是否存在风属性且未公开的怪兽
function c44663232.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and not c:IsPublic()
end
-- 效果发动时的费用处理，检索满足条件的风属性手卡怪兽并确认给对方观看
function c44663232.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44663232.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的1张手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c44663232.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽确认给对方观看
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将手卡洗切
	Duel.ShuffleHand(tp)
end
-- 效果发动时，创建一个永续效果，使双方玩家不能发动比已确认怪兽等级高的怪兽效果
function c44663232.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个影响对方玩家的永续效果，禁止发动效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetLabel(e:GetLabel()+1)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_OPPO_TURN)
	e1:SetValue(c44663232.val)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 判断效果是否为怪兽卡类型且其等级高于设定值
function c44663232.val(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLevelAbove(e:GetLabel())
end
