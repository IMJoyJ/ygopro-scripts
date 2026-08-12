--終焉の指名者
-- 效果：
-- 把1张手卡从游戏中除外才能发动。双方玩家在这次决斗中不能把为这张卡发动而除外的卡以及那些同名卡的效果发动。
function c28493337.initial_effect(c)
	-- 把1张手卡从游戏中除外才能发动。双方玩家在这次决斗中不能把为这张卡发动而除外的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28493337.cost)
	e1:SetTarget(c28493337.target)
	e1:SetOperation(c28493337.activate)
	c:RegisterEffect(e1)
end
-- 检查手卡中是否有可以作为除外代价的卡
function c28493337.cfilter(c)
	return c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理，选择并除外1张手卡
function c28493337.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 判断是否满足除外手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c28493337.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张手卡
	local g=Duel.SelectMatchingCard(tp,c28493337.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的发动目标确认
function c28493337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return true
	end
end
-- 发动效果，禁止对方发动除外卡的同名卡效果
function c28493337.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 禁止对方发动除外卡的同名卡效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c28493337.aclimit)
	e1:SetLabel(e:GetLabel())
	-- 将效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断效果是否生效，用于限制对方发动同名卡效果
function c28493337.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
