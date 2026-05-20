--龍大神
-- 效果：
-- ①：对方对怪兽的特殊召唤成功的场合发动。对方选额外卡组1张卡送去墓地。
function c63737050.initial_effect(c)
	-- ①：对方对怪兽的特殊召唤成功的场合发动。对方选额外卡组1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63737050,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c63737050.condition)
	e1:SetTarget(c63737050.target)
	e1:SetOperation(c63737050.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：由对方玩家特殊召唤的怪兽
function c63737050.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：特殊召唤成功的怪兽中不包含自身，且存在至少1只由对方特殊召唤的怪兽
function c63737050.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c63737050.cfilter,1,nil,tp)
end
-- 效果的目标处理：防止在同一连锁中重复触发，并设置送去墓地的操作信息
function c63737050.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置操作信息：对方额外卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 效果的处理：对方从自身额外卡组选择1张卡送去墓地
function c63737050.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中可以送去墓地的卡片
	local tg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if tg:GetCount()==0 then return end
	-- 提示对方玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=tg:Select(1-tp,1,1,nil)
	if g:GetCount()>0 then
		-- 将对方选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
