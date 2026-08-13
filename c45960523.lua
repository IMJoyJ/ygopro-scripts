--メタファイズ・ダイダロス
-- 效果：
-- ①：这张卡用「玄化」怪兽的效果特殊召唤成功的场合才能发动。这张卡以外的场上的特殊召唤的表侧表示怪兽全部除外。
-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从卡组把「玄化泰达路斯」以外的1张「玄化」卡除外。
function c45960523.initial_effect(c)
	-- ①：这张卡用「玄化」怪兽的效果特殊召唤成功的场合才能发动。这张卡以外的场上的特殊召唤的表侧表示怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45960523,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c45960523.rmcon)
	e1:SetTarget(c45960523.rmtg)
	e1:SetOperation(c45960523.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从卡组把「玄化泰达路斯」以外的1张「玄化」卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45960523,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c45960523.rmcon2)
	e2:SetCost(c45960523.rmcost2)
	e2:SetTarget(c45960523.rmtg2)
	e2:SetOperation(c45960523.rmop2)
	c:RegisterEffect(e2)
end
-- 触发判定：确认此次特殊召唤是由「玄化」怪兽的效果进行的特殊召唤（且自身是怪兽）。
function c45960523.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x105)
end
-- 筛选对象：场上表侧表示且为特殊召唤的怪兽，并且能够被除外。
function c45960523.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove() and c:IsFaceup()
end
-- 发动时确认：检索双方场上除自身以外符合除外条件的特殊召唤表侧表示怪兽，若存在则允许发动，并设置除外这些怪兽的操作信息。
function c45960523.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上以自己视角看除自身以外所有满足rmfilter条件的怪兽（即特殊召唤的表侧表示且可除外）。
	local g=Duel.GetMatchingGroup(c45960523.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：本次效果将除外g中的所有怪兽，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：重新筛选双方场上除自身以外符合条件的怪兽，将其全部表侧除外。
function c45960523.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取当前场上除自身以外所有符合条件的怪兽，以应对发动后场况变化。
	local g=Duel.GetMatchingGroup(c45960523.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将筛选出的怪兽全部除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定：确认当前是这张卡被除外的下一个回合的准备阶段。
function c45960523.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于这张卡被除外时的回合数+1，即处于被除外的下个回合。
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- ②效果的发动cost：先确认除外区的自身能否返回卡组作为代价；若能，则将自身返回卡组并洗牌作为发动代价。
function c45960523.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 执行cost：把除外区的这张卡弹回持有者卡组并洗牌（作为效果发动的代价）。
	Duel.SendtoDeck(e:GetHandler(),tp,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 筛选对象：卡组中除「玄化泰达路斯」以外的、「玄化」字段卡片，且可以被除外。
function c45960523.rmfilter2(c)
	return c:IsSetCard(0x105) and not c:IsCode(45960523) and c:IsAbleToRemove()
end
-- 发动时确认：卡组中存在符合条件的「玄化」卡，并设置除外其中1张卡的操作信息。
function c45960523.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组里是否存在至少1张满足rmfilter2条件的「玄化」卡，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c45960523.rmfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将除外卡组中的1张卡，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张符合条件的「玄化」卡并除外。
function c45960523.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要除外的卡（显示'请选择要除外的卡'）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己的卡组选择1张满足rmfilter2条件的「玄化」卡（选择结果存入g）。
	local g=Duel.SelectMatchingCard(tp,c45960523.rmfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张卡除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
