--魔神童
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。从卡组把1只恶魔族怪兽送去墓地。
function c48468330.initial_effect(c)
	-- ①：这张卡从手卡·卡组送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48468330,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,48468330)
	e1:SetCondition(c48468330.spcon)
	e1:SetTarget(c48468330.sptg)
	e1:SetOperation(c48468330.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。从卡组把1只恶魔族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48468330,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48468331)
	e2:SetTarget(c48468330.tgtg)
	e2:SetOperation(c48468330.tgop)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：卡片从前一个位置（手牌或卡组）被送去墓地时
function c48468330.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 效果的发动条件判断：确认场上是否有足够的怪兽区域，并且该卡可以被里侧守备表示特殊召唤
function c48468330.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否还有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置连锁处理信息：准备将此卡特殊召唤到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：执行特殊召唤操作并确认对方查看该卡
function c48468330.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否仍然存在于游戏中且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方玩家展示该卡的正面
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 用于筛选卡组中满足条件的恶魔族怪兽的过滤函数
function c48468330.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理前的准备阶段：检查卡组中是否存在满足条件的恶魔族怪兽并设置操作信息
function c48468330.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张满足条件的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48468330.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：准备从卡组送去墓地一张恶魔族怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择并把一张恶魔族怪兽送去墓地
function c48468330.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张满足条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c48468330.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的恶魔族怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
