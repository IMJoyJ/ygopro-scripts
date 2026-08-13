--sophiaの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以使用各自种族不同的自己场上3只怪兽来作的从手卡的仪式召唤则不能特殊召唤。
-- ①：自己·对方的主要阶段1，从手卡把这张卡和1张「影灵衣」魔法卡丢弃才能发动。那次阶段内，对方不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡仪式召唤时才能发动（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。这张卡以外的双方的场上·墓地的卡全部除外。
function c21105106.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以使用各自种族不同的自己场上3只怪兽来作的从手卡的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c21105106.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段1，从手卡把这张卡和1张「影灵衣」魔法卡丢弃才能发动。那次阶段内，对方不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c21105106.discon)
	e2:SetCost(c21105106.discost)
	e2:SetOperation(c21105106.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡仪式召唤时才能发动（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。这张卡以外的双方的场上·墓地的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c21105106.rmcon)
	e3:SetCost(c21105106.rmcost)
	e3:SetTarget(c21105106.rmtg)
	e3:SetOperation(c21105106.rmop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件限制：仅当此卡在手牌且该特殊召唤为仪式召唤时才允许被特殊召唤（即只能从手卡通过仪式召唤出场）。
function c21105106.splimit(e,se,sp,st)
	return e:GetHandler():IsLocation(LOCATION_HAND) and bit.band(st,SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
-- 仪式召唤素材过滤：选择自己场上（主要怪兽区）且为自己控制的怪兽作为素材。
function c21105106.mat_filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ①效果的发动条件：当前为主要阶段1（己方或对方的主要阶段1均可）。
function c21105106.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1，是则条件满足。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 代价过滤：从手卡选择1张卡名属于「影灵衣」且为魔法卡并可丢弃的卡。
function c21105106.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- ①代价判定：确认此卡可从手卡丢弃，且手卡存在符合条件的「影灵衣」魔法卡。
function c21105106.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 确认手卡中存在至少1张满足条件的「影灵衣」魔法卡。
		and Duel.IsExistingMatchingCard(c21105106.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示“请选择要丢弃的手牌”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张满足条件的「影灵衣」魔法卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c21105106.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选择的「影灵衣」魔法卡与这张卡一起送去墓地，作为代价丢弃。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- ①效果处理：在主要阶段1结束前，对对方适用‘不能从额外卡组把怪兽特殊召唤’的限制。
function c21105106.disop(e,tp,eg,ep,ev,re,r,rp)
	-- ①那次阶段内，对方不能从额外卡组把怪兽特殊召唤。②这张卡仪式召唤时才能发动（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c21105106.sumlimit)
	-- 将‘对方不能从额外卡组特殊召唤’的限制效果注册到场上，持续到主要阶段1结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤：只禁止从额外卡组进行的特殊召唤（对额外卡组的怪兽生效）。
function c21105106.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：这张卡仪式召唤成功时才能发动。
function c21105106.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- ②代价判定与自肃：本回合未进行通常召唤且特殊召唤次数恰好为1（即本次仪式召唤）时才能发动，发动后自己不能把其他怪兽通常召唤·特殊召唤。
function c21105106.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己尚未进行通常召唤（包括通常召唤的放置）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		-- 检查本回合自己进行的特殊召唤次数恰好为1（即此次仪式召唤），否则不满足发动条件。
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==1 end
	-- 这张卡若非以使用各自种族不同的自己场上3只怪兽来作的从手卡的仪式召唤则不能特殊召唤。②（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。这张卡以外的双方的场上·墓地的卡全部除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将‘自己不能特殊召唤’的限制效果注册到场上（②发动后的自肃）。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将‘自己不能通常召唤’的限制效果注册到场上（②发动后的自肃）。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	-- 将‘自己不能把怪兽盖放（通常召唤的放置）’的限制效果注册到场上（②发动后的自肃）。
	Duel.RegisterEffect(e3,tp)
end
-- ②效果发动时：检索双方场上·墓地中除这张卡以外所有可除外的卡，并设置操作信息。
function c21105106.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认双方场上·墓地中存在除这张卡以外至少1张可除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetHandler()) end
	-- 取得双方场上·墓地中除这张卡以外所有可除外的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	-- 设置本次效果将除外上述全部卡片的操作信息，用于连锁判定和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- ②效果处理：将双方场上·墓地中除这张卡以外的所有卡全部除外。
function c21105106.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得双方场上·墓地中可除外的卡，并排除这张卡自身。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	-- 将取得的所有卡以表侧表示除外，原因为效果除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 特殊召唤素材检查：素材必须恰好为3只，且3只怪兽的种族各不相同（对应‘各自种族不同’）。
function c21105106.mat_group_check(g)
	return #g==3 and g:GetClassCount(Card.GetRace)==3
end
