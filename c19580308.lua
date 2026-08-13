--DDラミア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把除「DD 拉弥亚」外的1张「DD」卡或「契约书」卡从自己的手卡·场上（表侧表示）送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19580308.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，把除「DD 拉弥亚」外的1张「DD」卡或「契约书」卡从自己的手卡·场上（表侧表示）送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19580308,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,19580308)
	e1:SetCost(c19580308.cost)
	e1:SetTarget(c19580308.target)
	e1:SetOperation(c19580308.operation)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：判定可作为代价的卡必须满足：在手卡或场上表侧表示、属于「DD」或「契约书」字段、不是「DD 拉弥亚」自身、可作为代价送去墓地；若没有可用主要怪兽区空位，则只可选择主要怪兽区内的卡（sequence<5）以腾出特殊召唤位置。
function c19580308.cfilter(c,ft)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0xaf,0xae)
		and not c:IsCode(19580308) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 发动代价处理：先取得主要怪兽区空位数；若空位为0则仅能选择场上的卡作为代价，否则可从手卡或场上表侧表示中选择；确认存在可选代价卡后，提示玩家选择1张并送去墓地作为发动代价。
function c19580308.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区的可用空格数，用于判断特殊召唤所需的区域条件并决定代价卡的可选范围。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_HAND+LOCATION_ONFIELD
	if ft==0 then loc=LOCATION_MZONE end
	-- 代价合法性检测：要求存在满足条件的代价卡，并且特殊召唤所需的区域条件允许（ft>-1），否则不能发动。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c19580308.cfilter,tp,loc,0,1,nil,ft) end
	-- 弹出选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从满足条件的卡中选出1张作为发动代价；可选范围为手卡或场上表侧表示，无空位时则仅限主要怪兽区的卡。
	local g=Duel.SelectMatchingCard(tp,c19580308.cfilter,tp,loc,0,1,1,nil,ft)
	-- 将选中的卡以代价（REASON_COST）送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动时目标检测：确认这张卡自身是否能够被特殊召唤；若能，则登记将对自身进行特殊召唤的处理信息。
function c19580308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁的特殊召唤操作信息：将这张卡自身作为特殊召唤对象，数量为1，用于相关时点和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先确认这张卡与发动时的效果仍有联系；若是，则将其表侧表示特殊召唤。若特殊召唤成功，再为这张卡附加一个不可被无效的“离场时改为除外”效果。
function c19580308.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方场上；若特殊召唤成功（返回数大于0）则继续附加离场除外的效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
