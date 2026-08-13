--M・HERO ダスク・クロウ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己墓地把1只「英雄」怪兽除外才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把「假面英雄 暮鸦」以外的1只「假面英雄」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：为「假面英雄 暮鸦」注册效果①（手牌存在时除外自己墓地1只「英雄」怪兽来特殊召唤自身）和效果②（召唤·特殊召唤成功时检索「假面英雄」怪兽加入手卡），其中效果②通过克隆e2分别注册了通常召唤和特殊召唤两个触发时点。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，从自己墓地把1只「英雄」怪兽除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把「假面英雄 暮鸦」以外的1只「假面英雄」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义效果①代价的过滤条件：选择自己墓地中的「英雄」怪兽，并且该怪兽可以作为代价被除外。
function s.costfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果①的代价处理：检查墓地是否存在可除外的「英雄」怪兽；存在时由玩家选择1只，将其表侧表示除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1张满足costfilter（「英雄」怪兽且可作为代价除外）的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择除外的卡片的提示信息，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从自己墓地选择1张满足costfilter的「英雄」怪兽，排除对象不包括e:GetHandler()（本卡在手牌，实际墓地不会包含它）。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的「英雄」怪兽以表侧表示除外，作为发动效果①的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①发动目标判定：确认自己主要怪兽区有可用空格，且这张卡能够被特殊召唤；否则不能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否留有可用于特殊召唤的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次效果将特殊召唤这张卡，供效果处理和连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：如果这张卡仍与当前连锁相关（未被无效或离场），则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②检索目标的过滤条件：不能是「假面英雄 暮鸦」自身（卡名id），必须是「假面英雄」字段的怪兽，且能够加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xa008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的目标判定：确认自己卡组·墓地存在满足检索条件的「假面英雄」怪兽，并设置操作信息为从卡组·墓地加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己卡组·墓地中是否存在至少1张满足thfilter的「假面英雄」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组·墓地选1张卡加入手卡；因为处理时才选择具体卡片，所以目标预设为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②处理：让玩家从卡组·墓地选择1张符合条件的「假面英雄」怪兽加入手卡，并向对方玩家展示该卡片。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择要加入手牌的卡片的提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组·墓地选择1张满足thfilter且不受王家长眠之谷影响的「假面英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的「假面英雄」怪兽以效果处理的方式加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
