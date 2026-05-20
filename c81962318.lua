--ドラグニティ－トリブル
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以从自己卡组把1只3星以下的龙族怪兽送去墓地。
function c81962318.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己卡组把1只3星以下的龙族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81962318,0))  --"检索送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c81962318.target)
	e1:SetOperation(c81962318.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中等级3以下、龙族且能送去墓地的怪兽
function c81962318.tgfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevelBelow(3) and c:IsAbleToGrave()
end
-- 效果发动的目标检测与操作信息设置函数
function c81962318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81962318.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只满足条件的怪兽送去墓地
function c81962318.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息，提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c81962318.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
