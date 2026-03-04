--返り咲く薔薇の大輪
-- 效果：
-- 自己场上存在的5星以上的植物族怪兽被破坏的场合，墓地存在的这张卡可以在自己场上特殊召唤。
function c12469386.initial_effect(c)
	-- 效果原文内容：自己场上存在的5星以上的植物族怪兽被破坏的场合，墓地存在的这张卡可以在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12469386,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c12469386.spcon)
	e1:SetTarget(c12469386.sptg)
	e1:SetOperation(c12469386.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，用于判断被破坏的怪兽是否为5星以上且为植物族。
function c12469386.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousLevelOnField()>=5 and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)~=0
end
-- 判断是否满足特殊召唤条件，即是否有满足filter条件的怪兽被破坏。
function c12469386.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c12469386.filter,1,e:GetHandler(),tp)
end
-- 设置特殊召唤的处理目标，确定是否可以发动此效果。
function c12469386.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤，并判断该卡是否可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息，用于记录将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作，将符合条件的卡特殊召唤到场上。
function c12469386.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡以正面表示的形式特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
