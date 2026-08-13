--エヴォルド・プレウロス
-- 效果：
-- 这张卡在自己场上被破坏送去墓地的场合，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
function c20855340.initial_effect(c)
	-- 这张卡在自己场上被破坏送去墓地的场合，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20855340,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c20855340.condition)
	e1:SetTarget(c20855340.target)
	e1:SetOperation(c20855340.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡在自己场上被破坏送去墓地，即此前位置为场上、此前控制者为发动玩家tp，且破坏原因为破坏。
function c20855340.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 筛选可特殊召唤的手牌怪兽：必须为名字带有「进化龙」字段的怪兽，且能够被当前效果正常特殊召唤（满足召唤条件与苏生限制）。
function c20855340.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标（发动合法性）处理：chk==0时，检查自己场上是否有可用主要怪兽区，并且手牌中是否存在至少1只满足c20855340.filter的「进化龙」怪兽。
function c20855340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否还有可用的主要怪兽区域（空格数>0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时再检查手牌中是否有至少1张满足特殊召唤条件的「进化龙」怪兽（不取对象，实际选择在处理时进行）。
		and Duel.IsExistingMatchingCard(c20855340.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次连锁登记为从手牌把1张卡特殊召唤的操作信息，供其他卡/效果检测本次效果的类别与目标。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：确认仍有可用怪兽区域后，提示玩家从手牌选择1只符合条件的「进化龙」怪兽，并以表侧表示特殊召唤到自己的主要怪兽区。
function c20855340.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认可用主要怪兽区数量；若没有空位则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示提示文字“请选择要特殊召唤的卡”，随后进入手牌选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中实际选择1张满足筛选条件（「进化龙」且可被特殊召唤）的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c20855340.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「进化龙」怪兽以表侧表示特殊召唤到自己的主要怪兽区；false,false表示仍需满足召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
