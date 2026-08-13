--スカー・ヴェンデット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把1张「复仇死者」魔法·陷阱卡加入手卡。
-- ②：这张卡在墓地存在的状态，场上的怪兽被解放的场合，从自己墓地把这张卡以外的1只不死族怪兽除外才能发动。这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「复仇死者」怪兽不能特殊召唤。
function c1855886.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡被送去墓地的场合才能发动。从卡组把1张「复仇死者」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1855886)
	e1:SetTarget(c1855886.thtg)
	e1:SetOperation(c1855886.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，场上的怪兽被解放的场合，从自己墓地把这张卡以外的1只不死族怪兽除外才能发动。这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「复仇死者」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,1855887)
	e2:SetCondition(c1855886.spcon)
	e2:SetCost(c1855886.spcost)
	e2:SetTarget(c1855886.sptg)
	e2:SetOperation(c1855886.spop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤条件：筛选卡名带有「复仇死者」字段的魔法·陷阱卡，且该卡能够被加入手卡。
function c1855886.thfilter(c)
	return c:IsSetCard(0x106) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动条件判定：存在符合条件的检索对象才可发动；同时设置本次处理将把1张卡从卡组加入手卡的操作信息。
function c1855886.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张满足检索条件的「复仇死者」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1855886.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理会将1张卡从卡组加入手卡，供后续效果联动与判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：玩家从卡组挑选1张符合条件的「复仇死者」魔法·陷阱卡加入手卡，并向对方展示该卡。
function c1855886.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中筛选并选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c1855886.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：场上有怪兽被解放，且被解放的怪兽中不包含本卡（本卡不是被解放的怪兽）。
function c1855886.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_MZONE) and not eg:IsContains(e:GetHandler())
end
-- 定义代价过滤条件：筛选本卡以外的不死族怪兽，且该卡可以作为代价从墓地除外。
function c1855886.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价处理：从自己墓地选择本卡以外的1只不死族怪兽，表侧表示除外作为发动代价。
function c1855886.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己墓地存在至少1只满足条件的本卡以外的不死族怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c1855886.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择本卡以外的1只不死族怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c1855886.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽表侧表示除外，处理原因为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标条件：自己主要怪兽区有空位，且本卡可以被效果特殊召唤；满足后登记特殊召唤本卡的操作信息。
function c1855886.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次处理将特殊召唤本卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理：空位检查后，将本卡特殊召唤，召唤成功则附加“自己不是「复仇死者」怪兽不能特殊召唤”的自肃效果。
function c1855886.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始前再次确认自己主要怪兽区仍有空位，否则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认本卡仍与该效果关联，并成功特殊召唤时，继续附加后续自肃效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「复仇死者」怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c1855886.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 自肃限制条件：不是「复仇死者」字段的怪兽不能进行特殊召唤。
function c1855886.splimit(e,c)
	return not c:IsSetCard(0x106)
end
