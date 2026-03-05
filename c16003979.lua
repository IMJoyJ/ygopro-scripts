--剣闘獣サジタリィ
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从手卡丢弃1张「剑斗兽」卡才能发动。自己从卡组抽2张。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 射斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c16003979.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从手卡丢弃1张「剑斗兽」卡才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16003979,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 判断是否为「剑斗兽」怪兽的效果特殊召唤
	e1:SetCondition(aux.gbspcon)
	e1:SetCost(c16003979.drcost)
	e1:SetTarget(c16003979.drtg)
	e1:SetOperation(c16003979.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 射斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16003979,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c16003979.spcon)
	e2:SetCost(c16003979.spcost)
	e2:SetTarget(c16003979.sptg)
	e2:SetOperation(c16003979.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断手卡中是否存在「剑斗兽」卡且可丢弃
function c16003979.drcfilter(c)
	return c:IsSetCard(0x1019) and c:IsDiscardable()
end
-- 效果处理：检查玩家手卡是否存在满足条件的「剑斗兽」卡并丢弃1张
function c16003979.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡是否存在满足条件的「剑斗兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16003979.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作，丢弃1张符合条件的「剑斗兽」卡
	Duel.DiscardHand(tp,c16003979.drcfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 效果处理：设置抽卡目标
function c16003979.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置抽卡效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标数量为2
	Duel.SetTargetParam(2)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡操作
function c16003979.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和目标数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽2张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断该卡是否参与过战斗
function c16003979.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果处理：将该卡送回卡组作为费用
function c16003979.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将该卡送回卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：判断卡组中是否存在「剑斗兽」怪兽且不是射斗本身
function c16003979.filter(c,e,tp)
	return not c:IsCode(16003979) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：设置特殊召唤目标
function c16003979.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在满足条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c16003979.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：执行特殊召唤操作
function c16003979.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c16003979.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
