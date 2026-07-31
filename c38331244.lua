--金神の戦鬼 アカスナ
local s,id,o=GetID()
-- 创建三个效果，分别对应特殊召唤条件、场上的怪兽表示形式改变和盖放陷阱卡的效果
function s.initial_effect(c)
	-- 此卡可以从手牌特殊召唤，条件是场上存在里侧表示的卡且能送入手牌或额外卡组，且有空怪兽区
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 此卡在主要阶段可以发动，支付1张手牌或场上的里侧表示陷阱卡作为代价，将对方场上至少1只表侧表示怪兽变为里侧守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 此卡在结束阶段可以发动，从牌组选择1张神之卡系列陷阱卡盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon2)
	e3:SetTarget(s.settg2)
	e3:SetOperation(s.setop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的卡（里侧表示、可作为费用送入手牌或额外卡组）
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 判断目标卡所在位置是否有空怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤的条件函数，检查场上是否存在满足spcfilter条件的卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足spcfilter条件的卡
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 特殊召唤的目标选择函数，选择要返回手牌的卡并设置标签
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足spcfilter条件的所有卡
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的操作函数，确认目标卡并送入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 向对方确认目标卡
	Duel.ConfirmCards(1-tp,g)
	-- 将目标卡以特殊召唤理由送入手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 盖放效果的发动条件，必须在主要阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤函数，用于判断手牌或场上的陷阱卡是否可以作为代价送去墓地
function s.tgfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFacedown())
		and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 盖放效果的费用支付函数，选择1张手牌或场上的里侧表示陷阱卡送去墓地
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足tgfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足tgfilter条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡以费用理由送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于判断对方场上的表侧表示怪兽是否可以变为里侧守备表示
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 盖放效果的目标选择函数，检查是否存在可变更为里侧守备表示的怪兽并设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足posfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取满足posfilter条件的所有怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，记录将要改变表示形式的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 盖放效果的操作函数，将符合条件的怪兽变为里侧守备表示
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足posfilter条件的所有怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- 结束阶段效果的发动条件，必须是自己的回合
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，用于判断牌组中是否存在神之卡系列陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1e4) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 结束阶段效果的目标选择函数，检查牌组中是否存在满足setfilter条件的卡
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查牌组中是否存在满足setfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 结束阶段效果的操作函数，从牌组选择1张神之卡系列陷阱卡盖放
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足setfilter条件的卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
