--黒羽の宝札
-- 效果：
-- 从手卡把1只名字带有「黑羽」的怪兽从游戏中除外发动。从自己卡组抽2张卡。这张卡发动的回合，自己不能把怪兽特殊召唤。「黑羽之宝札」在1回合只能发动1张。
function c4168871.initial_effect(c)
	-- 效果原文内容：从手卡把1只名字带有「黑羽」的怪兽从游戏中除外发动。从自己卡组抽2张卡。这张卡发动的回合，自己不能把怪兽特殊召唤。「黑羽之宝札」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4168871+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c4168871.cost)
	e1:SetTarget(c4168871.target)
	e1:SetOperation(c4168871.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中名字带有「黑羽」的怪兽（0x33为黑羽卡组编号），并且可以作为除外的代价。
function c4168871.filter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理函数，检查是否满足发动条件：本回合未进行过特殊召唤，且手牌中有至少1只名字带有「黑羽」的怪兽。
function c4168871.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已经进行过特殊召唤，若已进行则不能发动此效果。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 检查手牌中是否存在满足条件的「黑羽」怪兽，若无则不能发动此效果。
		and Duel.IsExistingMatchingCard(c4168871.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要除外的卡，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从玩家手牌中选择1张满足条件的「黑羽」怪兽作为除外的代价。
	local g=Duel.SelectMatchingCard(tp,c4168871.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽以正面表示的形式从游戏中除外，作为发动此效果的费用。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 效果原文内容：这张卡发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将一个永续效果注册给玩家，使其在本回合不能特殊召唤怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动时的目标设定函数，检查玩家是否可以抽2张卡，并设置抽卡目标。
function c4168871.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡，若不能则不能发动此效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2，表示要抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置效果操作信息，表示此效果为抽卡效果，目标为当前玩家，抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数，执行抽卡操作。
function c4168871.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标玩家和目标参数，即抽卡的玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，从玩家卡组中抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
