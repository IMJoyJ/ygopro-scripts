--コドモドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族怪兽不能特殊召唤，不能进行战斗阶段。
-- ①：这张卡被送去墓地的场合才能发动。从手卡把1只龙族怪兽特殊召唤。
function c35629124.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族怪兽不能特殊召唤，不能进行战斗阶段。①：这张卡被送去墓地的场合才能发动。从手卡把1只龙族怪兽特殊召唤。
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
	-- 添加自定义活动计数器，用于监控特殊召唤的怪兽是否全部为龙族怪兽
	Duel.AddCustomActivityCounter(35629124,ACTIVITY_SPSUMMON,c35629124.counterfilter)
end
-- 过滤函数：检测怪兽是否为表侧表示的龙族怪兽
function c35629124.counterfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup()
end
-- 代价与发动限制检查：检查本回合玩家是否未进入战斗阶段，且未特殊召唤过龙族以外的怪兽
function c35629124.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查，确认当前回合玩家未进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0
		-- 并确认当前回合玩家未特殊召唤过非龙族怪兽
		and Duel.GetCustomActivityCount(35629124,tp,ACTIVITY_SPSUMMON)==0 end
	-- 不能进行战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使玩家本回合不能进行战斗阶段的效果
	Duel.RegisterEffect(e1,tp)
	-- 自己不是龙族怪兽不能特殊召唤，从手卡把1只龙族怪兽特殊召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c35629124.sumlimit)
	-- 注册使玩家本回合只能特殊召唤龙族怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
-- 特殊召唤限制的过滤函数，限制只能特殊召唤龙族怪兽
function c35629124.sumlimit(e,c)
	return c:GetRace()~=RACE_DRAGON
end
-- 过滤函数：检测手牌中的卡是否为可以特殊召唤的龙族怪兽
function c35629124.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件检查：确认当前玩家怪兽区域有空位，且手牌中存在可特殊召唤的龙族怪兽
function c35629124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家怪兽区是否有空闲区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手牌中是否存在可特殊召唤的龙族怪兽
		and Duel.IsExistingMatchingCard(c35629124.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若怪兽区域有空位，选择手牌中1只龙族怪兽特殊召唤
function c35629124.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家怪兽区是否有空闲位置，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手牌中1只满足过滤条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c35629124.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选定的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
