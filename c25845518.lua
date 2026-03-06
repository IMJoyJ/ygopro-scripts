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
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c25845518.sptg)
	e2:SetOperation(c25845518.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽：怪兽卡、5星以上、龙骑兵团卡组、可以加入手牌
function c25845518.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsSetCard(0x29) and c:IsAbleToHand()
end
-- 效果处理时检查是否满足条件
function c25845518.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25845518.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息为将1张满足条件的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：选择满足条件的卡加入手牌并确认
function c25845518.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25845518.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的装备卡：表侧表示、有装备怪兽、装备怪兽为龙骑兵团、可以特殊召唤
function c25845518.filter(c,e,tp)
	return c:IsFaceup() and c:GetEquipTarget() and c:GetEquipTarget():IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理时检查是否满足条件
function c25845518.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c25845518.filter(chkc,e,tp) end
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法与陷阱区域是否存在满足条件的卡
		and Duel.IsExistingTarget(c25845518.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡作为对象
	local g=Duel.SelectTarget(tp,c25845518.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的卡特殊召唤
function c25845518.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
