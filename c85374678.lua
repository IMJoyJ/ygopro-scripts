--超量士グリーンレイヤー
-- 效果：
-- 「超级量子战士 绿光层」的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只「超级量子」怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，把手卡1张「超级量子」卡丢弃才能发动。自己从卡组抽1张。
function c85374678.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只「超级量子」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85374678,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,85374678)
	e1:SetTarget(c85374678.sptg)
	e1:SetOperation(c85374678.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，把手卡1张「超级量子」卡丢弃才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85374678,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,85374679)
	e3:SetCost(c85374678.drcost)
	e3:SetTarget(c85374678.drtg)
	e3:SetOperation(c85374678.drop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中可以特殊召唤的「超级量子」怪兽
function c85374678.filter(c,e,tp)
	return c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①（特殊召唤）的发动检测与效果分类设置
function c85374678.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的「超级量子」怪兽
		and Duel.IsExistingMatchingCard(c85374678.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①（特殊召唤）的效果处理函数
function c85374678.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只可以特殊召唤的「超级量子」怪兽
	local g=Duel.SelectMatchingCard(tp,c85374678.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中可以丢弃的「超级量子」卡片
function c85374678.drcfilter(c)
	return c:IsSetCard(0xdc) and c:IsDiscardable()
end
-- 效果②（抽卡）的发动代价检测与处理函数
function c85374678.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的「超级量子」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c85374678.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中的「超级量子」卡片作为发动代价
	Duel.DiscardHand(tp,c85374678.drcfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 效果②（抽卡）的发动检测与效果分类设置
function c85374678.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果影响对象为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息，预计让玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②（抽卡）的效果处理函数
function c85374678.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
