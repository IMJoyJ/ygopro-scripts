--影霊衣の戦士 エグザ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被效果解放的场合才能发动。从卡组把1只龙族「影灵衣」仪式怪兽加入手卡。
-- ②：这张卡被除外的场合，以自己的除外状态的1只其他的「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
function c53180020.initial_effect(c)
	-- ①：这张卡被效果解放的场合才能发动。从卡组把1只龙族「影灵衣」仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53180020,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,53180020)
	e1:SetCondition(c53180020.thcon)
	e1:SetTarget(c53180020.thtg)
	e1:SetOperation(c53180020.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己的除外状态的1只其他的「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53180020,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,53180020)
	e2:SetTarget(c53180020.sptg)
	e2:SetOperation(c53180020.spop)
	c:RegisterEffect(e2)
end
-- 判断导致解放的原因是否为“效果”解放（REASON_EFFECT），以满足①“被效果解放的场合”的发动条件。
function c53180020.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 筛选卡组中符合条件的卡：拥有「影灵衣」字段、是仪式怪兽、种族为龙族，并且可以被加入手卡。
function c53180020.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- ①效果的发动条件和目标合法性判定：若chk==0时检查卡组是否存在符合条件的检索目标，并设置处理信息为将卡组卡加入手卡。
function c53180020.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己的卡组中是否存在至少1张满足thfilter过滤条件的卡片，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c53180020.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明此效果处理时将把1张卡组里的卡加入手卡，供后续连锁判定（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时的操作：从卡组选出1张符合条件的龙族「影灵衣」仪式怪兽加入手卡，并展示给对手确认。
function c53180020.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示选择提示，要求其选择1张要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张满足thfilter条件的卡片（搜索目标）。
	local g=Duel.SelectMatchingCard(tp,c53180020.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以“效果”的原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选可作为②效果对象的怪兽：必须为表侧表示、拥有「影灵衣」字段，且能够被当前效果特殊召唤。
function c53180020.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xb4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与对象选择判定：需要自己场上有可用怪兽区域，且除外区存在1只除自身以外的符合条件的「影灵衣」怪兽。
function c53180020.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c53180020.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 在发动合法性检查时，首先要求自己的主要怪兽区存在空位，否则无法进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时要求除外区存在至少1只满足spfilter条件且不是本卡的「影灵衣」怪兽，可以作为特殊召唤的对象。
		and Duel.IsExistingTarget(c53180020.spfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	-- 显示选择提示，要求操作者选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己除外区选择1只满足spfilter条件的「影灵衣」怪兽，并将其锁定为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c53180020.spfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息：声明本次效果将把1只怪兽特殊召唤，对象已确定，供后续处理与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时的操作：取得对象怪兽，若对象仍与该效果存在关联，则将其表侧表示特殊召唤到自己场上。
function c53180020.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中最初选择的1张对象卡（②效果的目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以无召唤条件、无苏生限制的方式，将对象怪兽表侧表示特殊召唤到自己的主要怪兽区（攻击表示）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
