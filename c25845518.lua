--ドラグニティ・グロー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的卡组·墓地把1只5星以上的「龙骑兵团」怪兽加入手卡。
-- ②：把墓地的这张卡除外，以给「龙骑兵团」怪兽装备的自己的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
function c25845518.initial_effect(c)
	-- ①：从自己的卡组·墓地把1只5星以上的「龙骑兵团」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25845518,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25845518)
	e1:SetTarget(c25845518.target)
	e1:SetOperation(c25845518.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以给「龙骑兵团」怪兽装备的自己的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25845518,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,25845519)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果发动需将墓地的这张卡除外的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c25845518.sptg)
	e2:SetOperation(c25845518.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果检索的筛选条件：从卡组·墓地选择1只5星以上且属于「龙骑兵团」的怪兽，并且能够加入手卡。
function c25845518.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsSetCard(0x29) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息：卡组或墓地存在符合条件的「龙骑兵团」怪兽时才能发动，预设将1张卡加入手卡。
function c25845518.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查自己的卡组·墓地是否存在至少1只满足条件的「龙骑兵团」怪兽，作为能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c25845518.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设定效果处理时将1张卡加入手卡的操作信息，供连锁判定参考。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理时，从自己的卡组·墓地选出1只满足条件的「龙骑兵团」怪兽加入手卡，并向对方展示。
function c25845518.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「龙骑兵团」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25845518.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果对象筛选条件：自己魔陷区表侧表示、装备着「龙骑兵团」怪兽的怪兽卡，并且可以表侧守备表示特殊召唤。
function c25845518.filter(c,e,tp)
	return c:IsFaceup() and c:GetEquipTarget() and c:GetEquipTarget():IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件与取对象处理：自己主要怪兽区有空位且魔陷区存在满足条件的装备怪兽卡；选择其中1张作为效果对象。
function c25845518.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c25845518.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空位，作为②效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔陷区是否存在至少1张满足条件且能够成为效果对象的卡片。
		and Duel.IsExistingTarget(c25845518.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己魔陷区1张满足条件的装备怪兽卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c25845518.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设定效果处理时将对象卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时，将选中的对象卡以表侧守备表示特殊召唤到自己主要怪兽区。
function c25845518.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
