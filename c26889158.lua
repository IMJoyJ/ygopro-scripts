--転生炎獣ガゼル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「转生炎兽 羚羊」以外的「转生炎兽」怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「转生炎兽 羚羊」以外的1张「转生炎兽」卡送去墓地。
function c26889158.initial_effect(c)
	-- ①：「转生炎兽 羚羊」以外的「转生炎兽」怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26889158,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,26889158)
	e1:SetCondition(c26889158.spcon)
	e1:SetTarget(c26889158.sptg)
	e1:SetOperation(c26889158.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「转生炎兽 羚羊」以外的1张「转生炎兽」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26889158,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,26889159)
	e2:SetTarget(c26889158.tgtg)
	e2:SetOperation(c26889158.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 筛选满足「转生炎兽 羚羊」以外的「转生炎兽」怪兽且控制者为自己的卡，作为①效果的触发判定条件。
function c26889158.cfilter(c,tp)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and not c:IsCode(26889158) and c:IsControler(tp)
end
-- 检查本次送去墓地的卡组中是否存在至少1张满足cfilter条件的卡，即是否有「转生炎兽 羚羊」以外的「转生炎兽」怪兽被送去自己墓地。
function c26889158.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26889158.cfilter,1,nil,tp)
end
-- ①效果发动时检测：自己场上主要怪兽区有空位，且这张手卡能够被特殊召唤，以判断效果可否发动。
function c26889158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，向系统登记本次效果将特殊召唤这张卡（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理①效果：若此卡仍与效果关联，则将其从手卡特殊召唤。
function c26889158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤，将此卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选②效果所需的卡组对象：满足「转生炎兽」字段、卡名不是「转生炎兽 羚羊」且能够被送去墓地的卡。
function c26889158.tgfilter(c)
	return c:IsSetCard(0x119) and not c:IsCode(26889158) and c:IsAbleToGrave()
end
-- ②效果发动检测：卡组中存在符合条件的「转生炎兽」卡，并设置送去墓地的操作信息。
function c26889158.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合tgfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c26889158.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本次效果将从卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：提示玩家选择1张符合条件的卡，将其从卡组送去墓地。
function c26889158.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足tgfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c26889158.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那张卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
