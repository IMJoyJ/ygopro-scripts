--剣闘獣ラニスタ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，选择自己墓地存在的1只名字带有「剑斗兽」的怪兽才能发动。选择的怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 教斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c2067935.initial_effect(c)
	-- 『这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，选择自己墓地存在的1只名字带有「剑斗兽」的怪兽才能发动。选择的怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用。』
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2067935,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置e1的发动条件：此卡必须是用名字带有「剑斗兽」的怪兽的效果特殊召唤成功（召唤类型处于剑斗兽专用特殊召唤区间）。
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c2067935.rmtg)
	e1:SetOperation(c2067935.rmop)
	c:RegisterEffect(e1)
	-- 『这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 教斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2067935,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2067935.spcon)
	e2:SetCost(c2067935.spcost)
	e2:SetTarget(c2067935.sptg)
	e2:SetOperation(c2067935.spop)
	c:RegisterEffect(e2)
end
-- 定义墓地筛选函数rmfilter：选择自己墓地存在的1只名字带有「剑斗兽」的怪兽，且该怪兽是怪兽卡并可以被除外。
function c2067935.rmfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 目标选择函数rmtg：发动时检查自己墓地是否存在符合条件的剑斗兽怪兽；若存在，提示玩家选择1张并设为效果对象，同时登记除外操作信息。
function c2067935.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2067935.rmfilter(chkc) end
	-- 发动时（chk==0）检查自己墓地是否存在至少1只满足rmfilter且能被选为对象的剑斗兽怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c2067935.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家发送选择提示，提示内容为“请选择要除外的卡”，用于选择墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只符合条件的剑斗兽怪兽作为效果对象，该选择会与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c2067935.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次连锁的除外操作信息：将已选对象作为可能被除外的卡，数量为1，位于墓地，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理：将对象怪兽表侧表示除外；若此卡仍与效果关联且表侧表示，则给本卡附加“直到结束阶段当作和那只怪兽同名卡使用”的改名效果，并注册结束阶段时重置该改名效果的辅助效果。
function c2067935.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- 将对象怪兽以表侧表示从游戏中除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 『直到结束阶段时当作和那只怪兽同名卡使用。』
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 『直到结束阶段时当作和那只怪兽同名卡使用。』
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(2067935,2))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetOperation(c2067935.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段时重置本卡的改名效果，并展示本卡已恢复原名，同时向对方提示该处理发生。
function c2067935.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 以动画形式展示本卡被处理，表示其改名效果在结束阶段被重置。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家发送提示，告知其本卡的改名效果已被重置（显示对应的效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 设置e2的发动条件：本卡在本次战斗阶段中参加过战斗（进行过战斗）。
function c2067935.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- cost判定与支付：确认本卡可以回卡组作为代价；支付时将本卡洗回持有者卡组。
function c2067935.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将本卡送回持有者卡组并洗牌（作为发动效果的代价）。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义卡组筛选函数filter：选择「剑斗兽 教斗」以外的名字带有「剑斗兽」的怪兽，且该怪兽能被当前效果特殊召唤。
function c2067935.filter(c,e,tp)
	return not c:IsCode(2067935) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动判定（sptg）：若chk==0，则检查自己场上有怪兽区空格且卡组中存在至少1只符合条件的剑斗兽怪兽。
function c2067935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定（chk==0）：检查自己场上是否有可用的怪兽区空格；因本卡会先作为代价回卡组空出位置，所以空格数大于-1即可。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 发动条件判定：检查卡组中是否存在至少1只满足filter的剑斗兽怪兽。
		and Duel.IsExistingMatchingCard(c2067935.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁的特殊召唤操作信息：预计从卡组特殊召唤1只剑斗兽怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上仍有可用空位，则从卡组选择1只符合条件的剑斗兽怪兽，以表侧表示特殊召唤到自己场上，并给该怪兽注册一个以自身原卡号为标识的标记，供后续规则判定使用。
function c2067935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上有空余的怪兽区；若无空位则直接终止本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足filter的剑斗兽怪兽。
	local g=Duel.SelectMatchingCard(tp,c2067935.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的剑斗兽怪兽以表侧表示特殊召唤到自己场上（不忽略召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
