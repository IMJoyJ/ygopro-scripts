--メタファイズ・ダイダロス
-- 效果：
-- ①：这张卡用「玄化」怪兽的效果特殊召唤成功的场合才能发动。这张卡以外的场上的特殊召唤的表侧表示怪兽全部除外。
-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从卡组把「玄化泰达路斯」以外的1张「玄化」卡除外。
function c45960523.initial_effect(c)
	-- 效果原文内容：①：这张卡用「玄化」怪兽的效果特殊召唤成功的场合才能发动。这张卡以外的场上的特殊召唤的表侧表示怪兽全部除外。
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
	-- 效果原文内容：②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从卡组把「玄化泰达路斯」以外的1张「玄化」卡除外。
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
-- 规则层面操作：判断此卡是否为「玄化」怪兽特殊召唤成功
function c45960523.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x105)
end
-- 规则层面操作：过滤满足条件的怪兽（特殊召唤、可除外、正面表示）
function c45960523.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove() and c:IsFaceup()
end
-- 规则层面操作：设置连锁处理信息，确定要除外的怪兽数量
function c45960523.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：获取满足条件的场上怪兽组
	local g=Duel.GetMatchingGroup(c45960523.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 规则层面操作：设置连锁处理信息，确定要除外的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行除外效果，将符合条件的怪兽除外
function c45960523.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取满足条件的场上怪兽组（排除此卡）
	local g=Duel.GetMatchingGroup(c45960523.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 规则层面操作：将怪兽组除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 规则层面操作：判断是否为下个回合的准备阶段
function c45960523.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否为下个回合的准备阶段
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- 规则层面操作：支付除外代价，将此卡送回卡组
function c45960523.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 规则层面操作：将此卡送回卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),tp,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 规则层面操作：过滤满足条件的「玄化」卡（非此卡、可除外）
function c45960523.rmfilter2(c)
	return c:IsSetCard(0x105) and not c:IsCode(45960523) and c:IsAbleToRemove()
end
-- 规则层面操作：设置连锁处理信息，确定要除外的卡数量
function c45960523.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45960523.rmfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁处理信息，确定要除外的卡数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行除外效果，从卡组除外一张「玄化」卡
function c45960523.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面操作：选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c45960523.rmfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
