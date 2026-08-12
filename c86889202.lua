--番犬－ウォッチドッグ
-- 效果：
-- 「番犬-戴表看门狗」的效果1回合只能使用1次，这个效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的回合的主要阶段2把手卡1张魔法卡送去墓地才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。
function c86889202.initial_effect(c)
	-- ①：这张卡召唤成功的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c86889202.regop)
	c:RegisterEffect(e1)
	-- 「番犬-戴表看门狗」的效果1回合只能使用1次，这个效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的回合的主要阶段2把手卡1张魔法卡送去墓地才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86889202,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,86889202)
	e2:SetCondition(c86889202.condition)
	e2:SetCost(c86889202.cost)
	e2:SetTarget(c86889202.target)
	e2:SetOperation(c86889202.operation)
	c:RegisterEffect(e2)
end
-- 召唤成功时，给自身注册一个在回合结束时重置的Flag，用于标记此卡是在本回合召唤成功的
function c86889202.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(86889202,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 发动条件：本回合召唤成功且当前为主要阶段2
function c86889202.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否存在召唤成功的Flag，并且当前阶段为主要阶段2
	return e:GetHandler():GetFlagEffect(86889202)~=0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：手牌中的魔法卡且能作为代价送去墓地
function c86889202.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 发动代价：检查本回合是否未进行过特殊召唤，并从手牌将1张魔法卡送去墓地，同时适用本回合不能特殊召唤的誓约
function c86889202.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认本回合玩家未进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 并且手牌中存在至少1张满足过滤条件的魔法卡
		and Duel.IsExistingMatchingCard(c86889202.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择手牌中1张满足条件的魔法卡作为代价送去墓地
	Duel.DiscardHand(tp,c86889202.cfilter,1,1,REASON_COST)
	-- 这个效果发动的回合，自己不能把怪兽特殊召唤。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册“不能特殊召唤怪兽”的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：卡组中的永续魔法卡且可以盖放到场上
function c86889202.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 发动准备：检查魔法与陷阱区域是否有空位，以及卡组中是否存在可盖放的永续魔法卡
function c86889202.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己的魔法与陷阱区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且卡组中存在至少1张满足过滤条件的永续魔法卡
		and Duel.IsExistingMatchingCard(c86889202.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选择1张永续魔法卡在自己的魔法与陷阱区域盖放
function c86889202.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时魔法与陷阱区域没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足过滤条件的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c86889202.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的永续魔法卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
