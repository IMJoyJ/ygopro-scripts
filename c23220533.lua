--ホーリーナイツ・レイエル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1张「圣夜骑士」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外，以「圣夜骑士团·瑞尔」以外的自己墓地1只「圣夜骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c23220533.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「圣夜骑士」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23220533,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,23220533)
	e1:SetTarget(c23220533.thtg)
	e1:SetOperation(c23220533.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「圣夜骑士团·瑞尔」以外的自己墓地1只「圣夜骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23220533,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,23220534)
	e2:SetTarget(c23220533.sptg)
	e2:SetOperation(c23220533.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「圣夜骑士」魔法·陷阱卡
function c23220533.thfilter(c)
	return c:IsSetCard(0x159) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「圣夜骑士」魔法·陷阱卡
function c23220533.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「圣夜骑士」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23220533.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「圣夜骑士」魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组检索满足条件的「圣夜骑士」魔法·陷阱卡并加入手牌
function c23220533.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「圣夜骑士」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c23220533.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选满足条件的「圣夜骑士」怪兽
function c23220533.spfilter(c,e,tp)
	return c:IsSetCard(0x159) and c:IsType(TYPE_MONSTER) and not c:IsCode(23220533)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要特殊召唤的墓地中的「圣夜骑士」怪兽
function c23220533.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23220533.spfilter(chkc,e,tp) end
	-- 检查场上是否存在可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的「圣夜骑士」怪兽
		and Duel.IsExistingTarget(c23220533.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地中的「圣夜骑士」怪兽
	local g=Duel.SelectTarget(tp,c23220533.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置效果处理时要特殊召唤的墓地中的「圣夜骑士」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 将选中的墓地中的「圣夜骑士」怪兽特殊召唤
function c23220533.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
