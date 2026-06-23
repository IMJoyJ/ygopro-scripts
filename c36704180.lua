--幻影騎士団フラジャイルアーマー
-- 效果：
-- 「幻影骑士团 脆铠甲」的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「幻影骑士团」怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，把手卡1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡送去墓地才能发动。自己从卡组抽1张。
function c36704180.initial_effect(c)
	-- ①：自己场上的表侧表示的「幻影骑士团」怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36704180,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,36704180)
	e1:SetCondition(c36704180.condition)
	e1:SetTarget(c36704180.target)
	e1:SetOperation(c36704180.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把手卡1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡送去墓地才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36704180,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,36704181)
	e2:SetCost(c36704180.drcost)
	e2:SetTarget(c36704180.drtg)
	e2:SetOperation(c36704180.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被破坏的怪兽是否为我方场上表侧表示的幻影骑士团怪兽且由战斗或效果破坏
function c36704180.filter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0x10db) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否有满足条件的被破坏怪兽，即我方场上表侧表示的幻影骑士团怪兽被战斗或效果破坏
function c36704180.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36704180.filter,1,nil,tp)
end
-- 判断是否可以将此卡特殊召唤，需满足场上存在空位且此卡可以被特殊召唤
function c36704180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤此卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡从手卡特殊召唤到场上
function c36704180.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断手卡中是否包含幻影骑士团或幻影系列的魔法/陷阱卡
function c36704180.drcfilter(c)
	return (c:IsSetCard(0x10db) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToGraveAsCost()
end
-- 判断是否满足发动效果的费用，即此卡可以除外且手卡存在幻影骑士团或幻影系列魔法/陷阱卡
function c36704180.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在满足条件的幻影骑士团或幻影系列魔法/陷阱卡
		and Duel.IsExistingMatchingCard(c36704180.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将此卡从墓地除外作为发动费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡丢弃一张幻影骑士团或幻影系列的魔法/陷阱卡作为发动费用
	Duel.DiscardHand(tp,c36704180.drcfilter,1,1,REASON_COST,nil)
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c36704180.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作，让目标玩家从卡组抽1张卡
function c36704180.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
