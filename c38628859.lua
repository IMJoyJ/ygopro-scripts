--ダイノルフィア・ディプロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「恐啡肽狂龙」卡送去墓地。自己基本分是2000以下的场合，再给与对方500伤害。
-- ②：这张卡被战斗·效果破坏的场合，从自己墓地把1张陷阱卡除外才能发动。从自己墓地选「恐啡肽狂龙·梁龙」以外的1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
function c38628859.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「恐啡肽狂龙」卡送去墓地。自己基本分是2000以下的场合，再给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38628859)
	e1:SetTarget(c38628859.tgtg)
	e1:SetOperation(c38628859.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合，从自己墓地把1张陷阱卡除外才能发动。从自己墓地选「恐啡肽狂龙·梁龙」以外的1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,38628860)
	e3:SetCondition(c38628859.spcon)
	e3:SetCost(c38628859.spcost)
	e3:SetTarget(c38628859.sptg)
	e3:SetOperation(c38628859.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果中从卡组送墓的卡牌过滤器：必须是「恐啡肽狂龙」系列卡（setcode 0x173）且可以送去墓地。
function c38628859.tgfilter(c)
	return c:IsSetCard(0x173) and c:IsAbleToGrave()
end
-- ①效果的发动条件与操作信息设置：确认卡组存在符合条件的「恐啡肽狂龙」卡，登记将1张卡送去墓地的操作；若自己LP在2000以下，同时登记给对方500伤害的操作信息。
function c38628859.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张可以送去墓地的「恐啡肽狂龙」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38628859.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果将要把卡组中的1张卡送去墓地的操作信息，供后续时点/卡片效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 判断自己当前基本分是否≤2000，以决定是否追加伤害。
	if Duel.GetLP(tp)<=2000 then
		-- 登记将给对方造成500点效果伤害的操作信息（伤害类型为效果伤害）。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
-- ①效果的实际处理：从卡组选择1张符合条件的「恐啡肽狂龙」卡送去墓地；若成功送墓且自己LP≤2000，则先中断效果处理，再给对方500伤害。
function c38628859.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足tgfilter条件的「恐啡肽狂龙」卡（必选1张）。
	local g=Duel.SelectMatchingCard(tp,c38628859.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择到了卡，且该卡因效果被成功送去墓地，并且最终位于墓地（没有被其他效果代替）。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 并且确认发动者当前基本分在2000以下，满足追加伤害的LP条件。
		and Duel.GetLP(tp)<=2000 then
		-- 中断当前效果链，使随后的伤害处理不与送墓处理同时进行，避免错过时点。
		Duel.BreakEffect()
		-- 给对方造成500点效果伤害。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被战斗或效果破坏（破坏原因包含REASON_BATTLE或REASON_EFFECT）时才允许发动。
function c38628859.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- COST过滤器：从墓地选择的对象必须是陷阱卡，并且可以作为代价除外。
function c38628859.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价处理：确认墓地存在可除外的陷阱卡后，选择1张陷阱卡从墓地正面表示除外作为发动代价。
function c38628859.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价可支付性检查：自己墓地是否存在至少1张可以除外的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38628859.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足costfilter条件的陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c38628859.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的陷阱卡以正面表示除外，作为发动②效果的COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特召对象过滤器：必须是「恐啡肽狂龙」系列怪兽，不是本卡（恐啡肽狂龙·梁龙）自身，等级4以下，并且能够被当前效果特殊召唤。
function c38628859.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and not c:IsCode(38628859) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件检查：自己主要怪兽区有空位，且墓地存在符合条件的「恐啡肽狂龙」怪兽可以特殊召唤。
function c38628859.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查墓地是否存在至少1只满足spfilter条件的「恐啡肽狂龙」怪兽。
		and Duel.IsExistingMatchingCard(c38628859.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次效果将要从墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的实际处理：确认主要怪兽区仍有空位后，从墓地选择1只符合条件的「恐啡肽狂龙」怪兽，以正面表示特殊召唤到自己场上。
function c38628859.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter条件的「恐啡肽狂龙」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c38628859.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以正面表示特殊召唤到自己场上（不解除苏生限制、不检查召唤条件）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
