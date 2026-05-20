--邪帝家臣ルキウス
-- 效果：
-- 「邪帝家臣 卢基乌斯」的①②的效果1回合各能使用1次。
-- ①：把自己墓地1只5星以上的怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合才能发动。对方场上盖放的卡全部确认。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
function c58786132.initial_effect(c)
	-- ①：把自己墓地1只5星以上的怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,58786132)
	e1:SetCost(c58786132.spcost)
	e1:SetTarget(c58786132.sptg)
	e1:SetOperation(c58786132.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为上级召唤而被解放的场合才能发动。对方场上盖放的卡全部确认。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,58786133)
	e2:SetCondition(c58786132.condition)
	e2:SetTarget(c58786132.target)
	e2:SetOperation(c58786132.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中等级5以上且可以除外的怪兽
function c58786132.cfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的代价处理：将自己墓地1只5星以上的怪兽除外
function c58786132.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只等级5以上且可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58786132.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只等级5以上且可以除外的怪兽
	local g=Duel.SelectMatchingCard(tp,c58786132.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位并设置特殊召唤的操作信息
function c58786132.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理：注册本回合不能从额外卡组特殊召唤的限制，并将自身特殊召唤
function c58786132.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己不能从额外卡组把怪兽特殊召唤。②：这张卡为上级召唤而被解放的场合才能发动。对方场上盖放的卡全部确认。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c58786132.splimit)
	-- 注册不能从额外卡组特殊召唤怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制特殊召唤的来源为额外卡组
function c58786132.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 触发条件：这张卡因上级召唤而被解放
function c58786132.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 效果2的发动准备：检查对方场上是否有盖放的卡，并设置连锁限制
function c58786132.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置连锁限制，使对方不能对应此效果的发动来发动效果
	Duel.SetChainLimit(c58786132.chlimit)
end
-- 连锁限制函数：只有自己可以进行连锁（即对方不能对应发动效果）
function c58786132.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果2的效果处理：获取并确认对方场上所有盖放的卡
function c58786132.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有盖放的卡
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	-- 给玩家确认获取到的对方场上所有盖放的卡
	Duel.ConfirmCards(tp,g)
end
