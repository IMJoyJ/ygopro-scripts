--灰燼のアルバス
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「阿不思的落胤」使用。
-- ②：只要自己墓地有8星融合怪兽存在，这张卡的攻击力上升自己墓地的怪兽数量×200，对方不能把自己场上的其他的怪兽作为效果的对象。
-- ③：这张卡和融合怪兽在自己墓地存在的状态，自己场上的怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤。
function c37683547.initial_effect(c)
	-- 为这张卡注册卡名变更效果：在场上·墓地存在时，卡名当作「阿不思的落胤」（卡号68468459）使用。
	aux.EnableChangeCode(c,68468459,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：只要自己墓地有8星融合怪兽存在，这张卡的攻击力上升自己墓地的怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37683547.condition)
	e1:SetValue(c37683547.atkct)
	c:RegisterEffect(e1)
	-- ②：只要自己墓地有8星融合怪兽存在，对方不能把自己场上的其他的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c37683547.condition)
	e2:SetTarget(c37683547.tglimit)
	-- 设定“不能成为效果对象”的判定函数，使该效果仅在对方发动效果时适用，保护自己场上除自身以外的其他怪兽。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：这张卡和融合怪兽在自己墓地存在的状态，自己场上的怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,37683547)
	e3:SetCondition(c37683547.spcon)
	e3:SetTarget(c37683547.sptg)
	e3:SetOperation(c37683547.spop)
	c:RegisterEffect(e3)
end
-- 筛选墓地中等级为8的融合怪兽，作为②效果的发动条件判断。
function c37683547.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsLevel(8)
end
-- 检查效果持有者的墓地是否存在至少1只等级8的融合怪兽，用于②效果的共通条件。
function c37683547.condition(e)
	-- 检索效果持有者墓地中满足c37683547.filter条件的卡是否存在至少1张。
	return Duel.IsExistingMatchingCard(c37683547.filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 计算攻击力上升数值：自己墓地的怪兽数量×200。
function c37683547.atkct(e)
	-- 统计效果持有者墓地中的怪兽数量并乘以200，作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*200
end
-- 判断“其他的怪兽”：被选择对象不能是效果持有者自身。
function c37683547.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 筛选离场怪兽：该怪兽离场前控制者为发动者、离场前位于主要怪兽区、被对方的效果作为原因离场、且离场原因是效果处理。
function c37683547.cfilter(c,tp,rp)
	return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- ③的发动条件判定：本次离场的怪兽中存在满足上述筛选条件的卡；本卡不在离场怪兽中；且自己墓地中除本次离场卡外还存在融合怪兽。
function c37683547.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37683547.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
		-- 确认自己墓地中（排除本次离场的卡）至少有1只融合怪兽存在。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,eg,TYPE_FUSION)
end
-- 发动时点确认：自己场上有可用怪兽区域，且本卡可以特殊召唤。
function c37683547.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空闲的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本次效果处理将进行特殊召唤，对象是本卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若本卡仍与该效果保持关联，则将其特殊召唤。
function c37683547.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将本卡以表侧表示特殊召唤到其持有者的场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
