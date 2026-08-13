--返り咲く薔薇の大輪
-- 效果：
-- 自己场上存在的5星以上的植物族怪兽被破坏的场合，墓地存在的这张卡可以在自己场上特殊召唤。
function c12469386.initial_effect(c)
	-- 自己场上存在的5星以上的植物族怪兽被破坏的场合，墓地存在的这张卡可以在自己场上特殊召唤。
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
-- 筛选被破坏的怪兽，要求其破坏前控制者为tp、破坏前位于主要怪兽区、破坏前为表侧表示、破坏前等级为5星以上且种族包含植物族，即判断是否为“自己场上存在的5星以上的植物族怪兽”。
function c12469386.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousLevelOnField()>=5 and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)~=0
end
-- 效果发动条件判定：在被破坏的怪兽集合eg中，检查是否存在至少1只满足上述筛选条件且不是这张卡自身的怪兽。
function c12469386.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c12469386.filter,1,e:GetHandler(),tp)
end
-- 发动时进行合法性检查：确认自己场上存在可用的主要怪兽区空格，并且这张卡能够被当前效果特殊召唤。
function c12469386.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有空余的主要怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将操作信息登记为特殊召唤，对象为这张卡，数量为1，不指定玩家和位置，以配合连锁处理和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：获取这张卡自身，若它仍与当前效果保持关联，则执行特殊召唤。
function c12469386.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到tp的场上（不检查召唤条件、不解除苏生限制，表示形式为正面表示）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
