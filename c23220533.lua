--ホーリーナイツ・レイエル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1张「圣夜骑士」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外，以「圣夜骑士团·瑞尔」以外的自己墓地1只「圣夜骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c23220533.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤成功时才能发动。从卡组把1张「圣夜骑士」魔法·陷阱卡加入手卡。
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
	-- 设置效果②的发动代价为“把墓地的这张卡除外”，即使用辅助函数aux.bfgcost作为代价处理（检查能否除外并从墓地除外自身）。
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,23220534)
	e2:SetTarget(c23220533.sptg)
	e2:SetOperation(c23220533.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的检索过滤器：从卡组中筛选1张「圣夜骑士」字段的魔法·陷阱卡，且该卡能被加入手卡。
function c23220533.thfilter(c)
	return c:IsSetCard(0x159) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设置：在发动时确认卡组存在符合条件的卡片，并将本次操作标记为“检索并加入手卡”类别。
function c23220533.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动合法性检查阶段（chk==0），检查己方卡组中是否存在至少1张满足thfilter条件的卡，以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c23220533.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：本次效果将把1张卡片从卡组加入手卡（CATEGORY_TOHAND），用于配合连锁判定与效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择1张符合条件的「圣夜骑士」魔法·陷阱卡加入手卡，并让对方确认。
function c23220533.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家显示“请选择要加入手牌的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从卡组中筛选并选择1张满足thfilter条件的卡（对应检索动作）。
	local g=Duel.SelectMatchingCard(tp,c23220533.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡片以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索并加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的特殊召唤对象过滤器：必须是「圣夜骑士」怪兽、不是本卡（23220533）、且可以被特殊召唤。
function c23220533.spfilter(c,e,tp)
	return c:IsSetCard(0x159) and c:IsType(TYPE_MONSTER) and not c:IsCode(23220533)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象条件和目标选择：在发动时确认己方场上空位且墓地存在符合条件的对象，并设定对象只能选择自己墓地的满足条件的「圣夜骑士」怪兽。
function c23220533.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23220533.spfilter(chkc,e,tp) end
	-- 发动合法性检查阶段需确认己方的主要怪兽区有空位，才能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时还要确认墓地存在1只可作为对象的「圣夜骑士」怪兽（且不是本卡，满足spfilter），且该卡能成为效果对象。
		and Duel.IsExistingTarget(c23220533.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向己方玩家显示“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从墓地选择1只满足spfilter条件的「圣夜骑士」怪兽作为效果对象（取对象），并建立对象关联。
	local g=Duel.SelectTarget(tp,c23220533.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置效果处理信息：本次效果将把所选择的怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的实际处理：将对象怪兽以表侧攻击表示特殊召唤到己方场上（若对象仍与效果关联）。
function c23220533.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的第1个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上，遵守通常的苏生限制和召唤条件。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
