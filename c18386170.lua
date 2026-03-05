--彼岸の巡礼者 ダンテ
-- 效果：
-- 卡名不同的「彼岸」怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡不会成为对方的效果的对象。
-- ②：1回合1次，把手卡1张「彼岸」卡送去墓地才能发动。自己从卡组抽1张。这个效果在对方回合也能发动。
-- ③：场上的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。对方手卡随机选1张送去墓地。
function c18386170.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个满足条件的「彼岸」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c18386170.ffilter,3,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置该卡必须通过融合召唤方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	-- 设置该卡不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 1回合1次，把手卡1张「彼岸」卡送去墓地才能发动。自己从卡组抽1张。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c18386170.drcost)
	e3:SetTarget(c18386170.drtg)
	e3:SetOperation(c18386170.drop)
	c:RegisterEffect(e3)
	-- 场上的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。对方手卡随机选1张送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c18386170.hdcon)
	e4:SetTarget(c18386170.hdtg)
	e4:SetOperation(c18386170.hdop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数，确保融合素材为「彼岸」卡且不重复使用相同融合编号
function c18386170.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xb1) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 手牌过滤函数，筛选可作为cost的「彼岸」卡
function c18386170.cfilter(c)
	return c:IsSetCard(0xb1) and c:IsAbleToGraveAsCost()
end
-- 效果发动时检查手牌是否存在「彼岸」卡并丢弃一张
function c18386170.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在满足条件的「彼岸」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18386170.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张手牌作为效果发动的cost
	Duel.DiscardHand(tp,c18386170.cfilter,1,1,REASON_COST,nil)
end
-- 设置效果发动时的抽卡目标和参数
function c18386170.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡效果的执行函数
function c18386170.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断该卡是否因对方效果或战斗破坏被送去墓地
function c18386170.hdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)) or c:IsReason(REASON_BATTLE)
end
-- 设置效果发动时的弃牌目标和参数
function c18386170.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置效果操作信息为弃牌效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 处理对方手牌随机弃牌的效果
function c18386170.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选择的对方手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
