--灰燼のアルバス
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「阿不思的落胤」使用。
-- ②：只要自己墓地有8星融合怪兽存在，这张卡的攻击力上升自己墓地的怪兽数量×200，对方不能把自己场上的其他的怪兽作为效果的对象。
-- ③：这张卡和融合怪兽在自己墓地存在的状态，自己场上的怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤。
function c37683547.initial_effect(c)
	-- 使此卡在场上或墓地时视为「阿不思的落胤」使用
	aux.EnableChangeCode(c,68468459,LOCATION_MZONE+LOCATION_GRAVE)
	-- 只要自己墓地有8星融合怪兽存在，这张卡的攻击力上升自己墓地的怪兽数量×200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37683547.condition)
	e1:SetValue(c37683547.atkct)
	c:RegisterEffect(e1)
	-- 对方不能把自己场上的其他的怪兽作为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c37683547.condition)
	e2:SetTarget(c37683547.tglimit)
	-- 设置效果值为过滤函数，使目标不会成为对方的卡的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 自己场上的怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤
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
-- 过滤函数，用于筛选墓地中的8星融合怪兽
function c37683547.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsLevel(8)
end
-- 判断条件：自己墓地是否存在8星融合怪兽
function c37683547.condition(e)
	-- 检查自己墓地是否存在至少1张8星融合怪兽
	return Duel.IsExistingMatchingCard(c37683547.filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 计算函数，返回墓地怪兽数量乘以200作为攻击力加成
function c37683547.atkct(e)
	-- 获取自己墓地中怪兽的数量并乘以200作为攻击力加成
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*200
end
-- 目标限制函数，排除自身不被设为效果对象
function c37683547.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 过滤函数，用于筛选因对方效果离开场上的己方怪兽
function c37683547.cfilter(c,tp,rp)
	return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 特殊召唤发动条件：有己方怪兽因对方效果离场且墓地有融合怪兽
function c37683547.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37683547.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
		-- 检查墓地是否存在融合怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,eg,TYPE_FUSION)
end
-- 设置特殊召唤的发动条件和目标
function c37683547.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场上空位进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c37683547.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行将此卡特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
