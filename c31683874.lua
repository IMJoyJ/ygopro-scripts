--占い魔女 アンちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。从卡组把1只魔法师族怪兽除外。
function c31683874.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理抽卡时的特殊召唤，该效果只能在伤害步骤发动，且每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31683874,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,31683874)
	e1:SetCost(c31683874.spcost)
	e1:SetTarget(c31683874.sptg)
	e1:SetOperation(c31683874.spop)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，用于处理从手卡特殊召唤成功后的除外魔法师族怪兽，该效果具有延迟属性，每回合只能发动一次
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31683874,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,31683875)
	e2:SetCondition(c31683874.rmcon)
	e2:SetTarget(c31683874.rmtg)
	e2:SetOperation(c31683874.rmop)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤的费用条件，即确认该卡在抽卡时未被公开
function c31683874.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 设置特殊召唤的发动条件，检查场上是否有足够的怪兽区域以及该卡是否可以被特殊召唤
function c31683874.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的效果操作信息，告知对方将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤的操作，将该卡从手卡特殊召唤到场上
function c31683874.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以正面表示的形式特殊召唤到玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置除外效果的发动条件，确认该卡是从手卡特殊召唤成功的
function c31683874.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 定义除外效果的过滤函数，筛选出卡组中可以除外的魔法师族怪兽
function c31683874.rmfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end
-- 设置除外效果的发动条件，检查卡组中是否存在至少一张魔法师族怪兽
function c31683874.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31683874.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置除外效果的操作信息，告知对方将要除外一张魔法师族怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 执行除外操作，选择并除外一张魔法师族怪兽
function c31683874.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择一张魔法师族怪兽作为除外目标
	local g=Duel.SelectMatchingCard(tp,c31683874.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法师族怪兽以正面表示的形式除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
