--コドモドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族怪兽不能特殊召唤，不能进行战斗阶段。
-- ①：这张卡被送去墓地的场合才能发动。从手卡把1只龙族怪兽特殊召唤。
function c35629124.initial_effect(c)
	-- ①：这张卡被送去墓地的场合才能发动。从手卡把1只龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35629124,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,35629124)
	e1:SetCost(c35629124.spcost)
	e1:SetTarget(c35629124.sptg)
	e1:SetOperation(c35629124.spop)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合中特殊召唤的非龙族怪兽数量
	Duel.AddCustomActivityCounter(35629124,ACTIVITY_SPSUMMON,c35629124.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为龙族
function c35629124.counterfilter(c)
	return c:IsRace(RACE_DRAGON)
end
-- 效果发动时的费用支付处理，检查是否在该回合中未进行过战斗阶段且未进行过特殊召唤
function c35629124.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在该回合中是否未进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0
		-- 检查玩家在该回合中是否未进行过特殊召唤
		and Duel.GetCustomActivityCount(35629124,tp,ACTIVITY_SPSUMMON)==0 end
	-- 效果发动时，使对手不能进入战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 效果发动时，使对手不能特殊召唤非龙族怪兽
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c35629124.sumlimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制非龙族怪兽的特殊召唤
function c35629124.sumlimit(e,c)
	return c:GetRace()~=RACE_DRAGON
end
-- 过滤函数，筛选手牌中可以特殊召唤的龙族怪兽
function c35629124.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件，检查场上是否有足够的空间并确认手牌中存在符合条件的龙族怪兽
function c35629124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在符合条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c35629124.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的卡牌类别为龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，选择并特殊召唤符合条件的龙族怪兽
function c35629124.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家手牌中选择符合条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c35629124.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的龙族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
