--ラインモンスター Kホース
-- 效果：
-- 这张卡召唤成功时，选择对方的魔法与陷阱卡区域盖放的1张卡才能发动。把盖放的那张卡确认，陷阱卡的场合，那张卡破坏。不是的场合，回到原状。这个效果把陷阱卡破坏时，可以把以下效果发动。
-- ●从手卡把1只地属性·3星怪兽表侧守备表示特殊召唤。
function c41493640.initial_effect(c)
	-- 这张卡召唤成功时，选择对方的魔法与陷阱卡区域盖放的1张卡才能发动。把盖放的那张卡确认，陷阱卡的场合，那张卡破坏。不是的场合，回到原状。这个效果把陷阱卡破坏时，可以把以下效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41493640,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c41493640.target)
	e1:SetOperation(c41493640.operation)
	c:RegisterEffect(e1)
	-- ●从手卡把1只地属性·3星怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41493640,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+41493640)
	e2:SetTarget(c41493640.sptg)
	e2:SetOperation(c41493640.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选对方魔法与陷阱区域盖放的里侧表示的卡（不包括额外区域的卡）
function c41493640.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 效果处理函数，用于选择对方魔法与陷阱区域的1张里侧表示的卡作为对象
function c41493640.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c41493640.filter(chkc) end
	-- 判断是否满足选择对象的条件，即对方魔法与陷阱区域是否存在1张里侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(c41493640.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择对方魔法与陷阱区域的1张里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方魔法与陷阱区域的1张里侧表示的卡作为对象
	Duel.SelectTarget(tp,c41493640.filter,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 效果处理函数，用于处理选择对象卡的确认与破坏逻辑，若为陷阱卡则触发后续特殊召唤效果
function c41493640.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	-- 向玩家确认对象卡的卡面内容
	Duel.ConfirmCards(tp,tc)
	-- 判断对象卡是否为陷阱卡，若是则将其破坏
	if tc:IsType(TYPE_TRAP) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 触发自定义事件，用于发动后续特殊召唤效果
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+41493640,e,0,tp,tp,0)
		end
	end
end
-- 过滤函数，用于筛选手牌中满足条件的地属性3星怪兽
function c41493640.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的处理函数，用于判断是否可以发动特殊召唤效果
function c41493640.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手牌中是否存在满足条件的地属性3星怪兽
		and Duel.IsExistingMatchingCard(c41493640.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理函数，用于选择并特殊召唤符合条件的怪兽
function c41493640.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,c41493640.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
