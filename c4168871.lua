--黒羽の宝札
-- 效果：
-- 从手卡把1只名字带有「黑羽」的怪兽从游戏中除外发动。从自己卡组抽2张卡。这张卡发动的回合，自己不能把怪兽特殊召唤。「黑羽之宝札」在1回合只能发动1张。
function c4168871.initial_effect(c)
	-- 从手卡把1只名字带有「黑羽」的怪兽从游戏中除外发动。从自己卡组抽2张卡。「黑羽之宝札」在1回合只能发动1张。
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
-- 过滤函数：筛选出名字带有「黑羽」的怪兽卡，并且该卡可以作为代价从游戏中除外，用于从手牌选择发动代价。
function c4168871.filter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价函数的检查阶段：确认本回合尚未特殊召唤过，且手牌中存在至少1张满足 c4168871.filter 的「黑羽」怪兽，才允许发动并支付代价。
function c4168871.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp本回合的特殊召唤次数为0，即只有在还没有进行过特殊召唤时才能发动此卡（与自肃对应的发动限制）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 同时检查手牌中是否存在至少1张符合条件的「黑羽」怪兽作为除外代价；若两者都满足，代价可以支付。
		and Duel.IsExistingMatchingCard(c4168871.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家tp显示选择提示，提示类型为请选择要除外的卡，让玩家在后续选择中知道要选择手牌的「黑羽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家tp从自己的手牌中选择1张满足 filter 的「黑羽」怪兽（min=max=1），作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c4168871.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的这张「黑羽」怪兽以表侧表示从游戏中除外，作为发动本卡的代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 从自己卡组抽2张卡。这张卡发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将刚创建的“此回合不能特殊召唤”的永续效果注册给玩家tp，使其从此刻起对tp生效，并在结束阶段自动重置消除。
	Duel.RegisterEffect(e1,tp)
end
-- 目标函数：在效果发动时确认玩家tp可以抽2张卡，并记录目标玩家为tp、抽卡参数为2，同时登记抽卡操作信息。
function c4168871.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：判断玩家tp是否能够进行效果抽卡且至少能抽2张；若不能则不满足发动条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设为tp，即抽卡效果的作用对象是发动者本人。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设为2，表示效果处理时需要抽2张卡。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本连锁的处理分类为CATEGORY_DRAW（抽卡），目标玩家为tp，参数为2张；供发动后的召唤反应等效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从连锁信息中取出之前记录的目标玩家p和抽卡数量d，并执行抽卡。
function c4168871.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁记录的目标玩家p与目标参数d（即抽卡对象和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以REASON_EFFECT的原因抽取d张卡，完成抽卡效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
