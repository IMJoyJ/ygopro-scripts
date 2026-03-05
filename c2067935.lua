--剣闘獣ラニスタ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，选择自己墓地存在的1只名字带有「剑斗兽」的怪兽才能发动。选择的怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 教斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c2067935.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，选择自己墓地存在的1只名字带有「剑斗兽」的怪兽才能发动。选择的怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2067935,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 效果触发条件：该卡通过「剑斗兽」怪兽的效果特殊召唤成功
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c2067935.rmtg)
	e1:SetOperation(c2067935.rmop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 教斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
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
-- 过滤函数：用于筛选墓地中的「剑斗兽」怪兽（必须是怪兽卡且可以除外）
function c2067935.rmfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果目标选择函数：选择1只自己墓地中的「剑斗兽」怪兽作为除外对象
function c2067935.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2067935.rmfilter(chkc) end
	-- 判断是否满足发动条件：确认场上是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c2067935.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标：从自己墓地选择1只符合条件的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c2067935.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息：将要除外的怪兽设置为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：将选中的怪兽除外，并使自身获得其卡号直到结束阶段
function c2067935.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果目标：获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- 将目标怪兽除外：以效果原因将目标怪兽从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 创建效果：使自身获得目标怪兽的卡号
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 创建持续效果：在结束阶段时重置自身获得的卡号效果
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
-- 结束阶段处理函数：重置获得的卡号效果并提示效果发动
function c2067935.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 战斗阶段结束时的发动条件：该卡在战斗阶段中参与过战斗
function c2067935.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤的费用支付函数：将自身送入卡组作为费用
function c2067935.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将自身送入卡组作为费用
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：用于筛选可以特殊召唤的「剑斗兽」怪兽（排除自身）
function c2067935.filter(c,e,tp)
	return not c:IsCode(2067935) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标选择函数：选择1只可以特殊召唤的「剑斗兽」怪兽
function c2067935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断是否满足发动条件：确认卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c2067935.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果操作信息：将要特殊召唤的怪兽设置为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤处理函数：从卡组特殊召唤1只符合条件的怪兽
function c2067935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：确认场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c2067935.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
