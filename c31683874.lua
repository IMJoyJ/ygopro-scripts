--占い魔女 アンちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。从卡组把1只魔法师族怪兽除外。
function c31683874.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。从卡组把1只魔法师族怪兽除外。
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
-- 作为①效果的发动代价，检查这张卡是否处于非公开状态（若已公开则不能再展示），以符合“把这张卡给对方观看”的发动条件。
function c31683874.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果发动时进行合法性检查：自己的主要怪兽区有空位，且这张卡能够被特殊召唤。
function c31683874.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁要特殊召唤这张卡的操作信息，明确效果类别为特殊召唤，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理时，先确认这张卡仍与效果保持关联（未离开手牌或效果被重置），若成立则将其特殊召唤。
function c31683874.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到发动玩家的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：判断这张卡是否是从手卡特殊召唤成功（即特殊召唤前所在位置为手牌）。
function c31683874.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 从卡组筛选满足条件的卡片：必须是魔法师族怪兽，且当前可以被除外。
function c31683874.rmfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end
-- ②效果发动时进行合法性检查：卡组中存在至少1只可除外的魔法师族怪兽；并设置操作信息为除外卡组的1张卡。
function c31683874.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足筛选条件的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31683874.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理将除外卡组中的1张卡（不取对象，处理时选择），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，提示玩家选择要除外的卡，从卡组选择1只符合条件的魔法师族怪兽表侧除外。
function c31683874.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要除外的卡”的系统提示，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的卡组中筛选并选择1张满足“魔法师族且可除外”条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c31683874.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡片以表侧表示除外，处理原因为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
