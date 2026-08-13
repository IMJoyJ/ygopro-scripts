--クリボルト
-- 效果：
-- 自己的主要阶段时，选择持有超量素材的1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，从自己卡组把1只「电击栗子」特殊召唤。这张卡不能作为同调素材。
function c40817915.initial_effect(c)
	-- 自己的主要阶段时，选择持有超量素材的1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，从自己卡组把1只「电击栗子」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40817915,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40817915.target)
	e1:SetOperation(c40817915.activate)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示且持有超量素材的超量怪兽，用于作为取除素材的对象。
function c40817915.ofilter(c)
	return c:IsFaceup() and c:GetOverlayCount()~=0
end
-- 过滤函数：筛选自己卡组中卡名为「电击栗子」且可以特殊召唤的卡。
function c40817915.spfilter(c,e,tp)
	return c:IsCode(40817915) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：检查发动条件（场上存在可取素材的对象、卡组有可特殊召唤的「电击栗子」、自己怪兽区有空位），并让玩家选择1只符合条件的超量怪兽作为对象；连锁处理时还会校验对象是否合法。
function c40817915.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40817915.ofilter(chkc) end
	-- 发动条件检查：自己主要怪兽区是否有空位，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：场上是否存在1只表侧表示且持有超量素材的超量怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c40817915.ofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 发动条件检查：卡组中是否存在1张可以特殊召唤的「电击栗子」。
		and Duel.IsExistingMatchingCard(c40817915.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 显示选择提示“请选择要取除超量素材的怪兽”，供玩家选择对象时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 让玩家从双方场上选择1只表侧表示且持有超量素材的超量怪兽，将其设为效果对象。
	local g=Duel.SelectTarget(tp,c40817915.ofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本效果将从卡组特殊召唤1只怪兽；由于具体卡在处理时选择，对象暂时为空。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取除对象怪兽的1个超量素材，然后从卡组特殊召唤1只「电击栗子」；若无法处理则效果不适用。
function c40817915.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择作为对象的超量怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:GetOverlayCount()==0 then return end
	tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 若自己主要怪兽区没有空位，则不能特殊召唤，效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示“请选择要特殊召唤的卡”，供玩家选择卡组中的「电击栗子」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张可以特殊召唤的「电击栗子」。
	local g=Duel.SelectMatchingCard(tp,c40817915.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「电击栗子」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
