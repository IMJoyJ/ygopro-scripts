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
-- 效果发动条件：这张卡从手卡或卡组被送去墓地时，满足发动条件（判定其之前位置为手卡或卡组）。
function c48468330.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤的发动可行性检查：确认可以发动时，需要己方主要怪兽区域有空位且这张卡能够以里侧守备表示特殊召唤。
function c48468330.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息：标明本效果将进行特殊召唤，供系统识别与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联，则将其以里侧守备表示特殊召唤到己方场上；成功后将那张卡给对方玩家确认。
function c48468330.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否仍与发动时一样保持关联，并尝试将其以里侧守备表示特殊召唤，且确认特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方玩家确认这张以里侧守备表示特殊召唤的卡（规则要求里侧守备特殊召唤的怪兽需向对方确认）。
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 过滤条件：选择卡组中的1只恶魔族怪兽，且该怪兽能够被送去墓地。
function c48468330.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果发动时的目标选择：确认卡组是否存在符合条件的恶魔族怪兽，并设置本次效果将把卡组中的1只怪兽送去墓地的操作信息。
function c48468330.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1只以上满足条件的恶魔族怪兽（种族为恶魔族、是怪兽卡且能被送去墓地）。
	if chk==0 then return Duel.IsExistingMatchingCard(c48468330.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果为从卡组将1张卡送去墓地，供系统记录和后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：由玩家从卡组选择1只符合条件的恶魔族怪兽，将其送去墓地。
function c48468330.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组选择1张满足条件的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,c48468330.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因从卡组送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
