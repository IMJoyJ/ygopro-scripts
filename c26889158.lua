--転生炎獣ガゼル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「转生炎兽 羚羊」以外的「转生炎兽」怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「转生炎兽 羚羊」以外的1张「转生炎兽」卡送去墓地。
function c26889158.initial_effect(c)
	-- 效果原文：①：「转生炎兽 羚羊」以外的「转生炎兽」怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 效果原文：②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「转生炎兽 羚羊」以外的1张「转生炎兽」卡送去墓地。
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
-- 过滤函数：检查目标是否为「转生炎兽」怪兽且控制者为玩家tp且不是「转生炎兽 羚羊」本身
function c26889158.cfilter(c,tp)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and not c:IsCode(26889158) and c:IsControler(tp)
end
-- 条件函数：判断是否有满足条件的「转生炎兽」怪兽被送去墓地
function c26889158.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26889158.cfilter,1,nil,tp)
end
-- 目标函数：判断是否可以将自身特殊召唤到场上
function c26889158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将自身特殊召唤到场上
function c26889158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面：执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检查目标是否为「转生炎兽」卡且不是「转生炎兽 羚羊」且可以送去墓地
function c26889158.tgfilter(c)
	return c:IsSetCard(0x119) and not c:IsCode(26889158) and c:IsAbleToGrave()
end
-- 目标函数：判断是否可以从卡组选择一张「转生炎兽」卡送去墓地
function c26889158.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断卡组中是否存在满足条件的「转生炎兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c26889158.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置效果处理信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择一张「转生炎兽」卡送去墓地
function c26889158.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面：从卡组选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c26889158.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
