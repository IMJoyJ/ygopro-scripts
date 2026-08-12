--剣闘獣ムルミロ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，把场上1只表侧表示怪兽破坏。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 鱼斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c5975022.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，把场上1只表侧表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5975022,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果发动条件为：这张卡用「剑斗兽」怪兽的效果特殊召唤成功。
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c5975022.destg)
	e1:SetOperation(c5975022.desop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 鱼斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5975022,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c5975022.spcon)
	e2:SetCost(c5975022.spcost)
	e2:SetTarget(c5975022.sptg)
	e2:SetOperation(c5975022.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的怪兽。
function c5975022.desfilter(c)
	return c:IsFaceup()
end
-- 破坏效果的目标确认与选择阶段，检查是否存在可选对象并进行取对象操作，设置破坏操作信息。
function c5975022.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5975022.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家在双方场上选择1只表侧表示的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c5975022.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理阶段，获取目标并将其破坏。
function c5975022.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的唯一对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查自身是否在本次战斗阶段进行过战斗，作为特殊召唤效果的发动条件。
function c5975022.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 检查并执行将自身送回卡组的代价。
function c5975022.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将自身回到卡组并洗牌。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：卡组中「剑斗兽 鱼斗」以外的、「剑斗兽」怪兽、且可以特殊召唤。
function c5975022.filter(c,e,tp)
	return not c:IsCode(5975022) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标确认阶段，检查怪兽区域空位以及卡组中是否存在可特召的「剑斗兽」怪兽。
function c5975022.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价回卡组，所以空位要求为大于-1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足过滤条件的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(c5975022.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理阶段，从卡组选择1只「剑斗兽」怪兽特殊召唤到场上。
function c5975022.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c5975022.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
