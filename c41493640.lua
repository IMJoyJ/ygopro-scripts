--ラインモンスター Kホース
-- 效果：
-- 这张卡召唤成功时，选择对方的魔法与陷阱卡区域盖放的1张卡才能发动。把盖放的那张卡确认，陷阱卡的场合，那张卡破坏。不是的场合，回到原状。这个效果把陷阱卡破坏时，可以把以下效果发动。
-- ●从手卡把1只地属性·3星怪兽表侧守备表示特殊召唤。
function c41493640.initial_effect(c)
	-- 这张卡召唤成功时，选择对方的魔法与陷阱卡区域盖放的1张卡才能发动。把盖放的那张卡确认，陷阱卡的场合，那张卡破坏。不是的场合，回到原状。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41493640,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c41493640.target)
	e1:SetOperation(c41493640.operation)
	c:RegisterEffect(e1)
	-- 这个效果把陷阱卡破坏时，可以把以下效果发动。●从手卡把1只地属性·3星怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41493640,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+41493640)
	e2:SetTarget(c41493640.sptg)
	e2:SetOperation(c41493640.spop)
	c:RegisterEffect(e2)
end
-- 选择对象的过滤器：卡必须是里侧表示且不在场地魔法格（序列5）上，即对方魔法与陷阱区域里侧覆盖的卡。
function c41493640.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 作为召唤成功时诱发效果的发动条件和目标选择函数：检查能否选择对方魔法与陷阱区1张里侧覆盖卡为对象，并让玩家进行选择。
function c41493640.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c41493640.filter(chkc) end
	-- 发动合法性检查（chk==0）时，确认对方魔法与陷阱区存在至少1张符合条件的里侧覆盖卡作为对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c41493640.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 向操作玩家发送提示消息，提示选择里侧表示的卡，用于卡片选择界面的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让操作玩家从对方魔法与陷阱区选择1张里侧覆盖卡，并注册为当前连锁的效果对象。
	Duel.SelectTarget(tp,c41493640.filter,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 效果处理时：若对象卡仍与效果关联且为里侧表示，则将其展示；若是陷阱卡则破坏，破坏成功后满足条件时触发后续特殊召唤效果；若不是陷阱卡则不作任何处理，保持原状。
function c41493640.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	-- 向己方玩家确认展示对象卡，令双方均可看到该卡的详细信息。
	Duel.ConfirmCards(tp,tc)
	-- 若对象卡是陷阱卡，则将其以效果破坏；只有当破坏成功（返回值非0）时才继续后续处理。
	if tc:IsType(TYPE_TRAP) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 以本卡为触发来源，产生一个自定义事件（EVENT_CUSTOM+41493640），用于触发第二个效果，对应“这个效果把陷阱卡破坏时”的时点。
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+41493640,e,0,tp,tp,0)
		end
	end
end
-- 特殊召唤的过滤器：判断手卡怪兽是否为地属性·3星，并且能否以表侧守备表示特殊召唤。
function c41493640.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤诱发效果的发动条件检查：自己主要怪兽区有空位，且手卡存在至少1只符合条件的怪兽可以特殊召唤。
function c41493640.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格；若无空格则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查手卡中是否存在1只满足条件的地属性·3星怪兽可被特殊召唤。
		and Duel.IsExistingMatchingCard(c41493640.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息，预告本效果将进行1次从手卡的特殊召唤，供相关卡片（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果处理：若仍有空位，则从手卡选择1只符合条件的怪兽，以表侧守备表示特殊召唤。
function c41493640.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区已无空位，则特殊召唤处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发送提示消息，提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从手卡选择1张满足条件（地属性·3星且可以特殊召唤）的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c41493640.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上，且不检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
