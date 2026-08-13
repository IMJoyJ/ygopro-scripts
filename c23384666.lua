--機巧蛙－磐盾多邇具久
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选攻击力和守备力的数值相同的1只机械族怪兽在卡组最上面放置。
-- ②：把墓地的这张卡除外，以攻击力和守备力的数值相同的自己墓地1只机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c23384666.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选攻击力和守备力的数值相同的1只机械族怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23384666,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,23384666)
	e1:SetTarget(c23384666.tdtg)
	e1:SetOperation(c23384666.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以攻击力和守备力的数值相同的自己墓地1只机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23384666,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,23384667)
	-- 设置②效果的发动费用为将墓地的这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c23384666.sptg)
	e3:SetOperation(c23384666.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果使用的卡组检索过滤函数：筛选攻击力与守备力数值相同且种族为机械族的怪兽。
function c23384666.tdfilter(c)
	-- 判断卡片的攻击力和守备力数值相同，并且种族为机械族。
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
end
-- ①效果的发动条件判定函数：在发动时检查卡组是否存在至少1只符合条件的机械族怪兽，且卡组数量大于1（保证检索后能放置在卡组最上方）。
function c23384666.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查卡组中是否存在至少1张满足tdfilter的机械族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23384666.tdfilter,tp,LOCATION_DECK,0,1,nil)
		-- 同时检查我方卡组数量大于1，确保发动后能将选出的怪兽放置到卡组最上面。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- ①效果处理时的操作：从卡组选择1只攻击力与守备力相同的机械族怪兽，洗切卡组后将其放置在卡组最上面，并向双方确认。
function c23384666.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要放置到卡组最上面的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23384666,2))  --"请选择要放置到卡组最上面的卡"
	-- 从卡组中选择1张满足tdfilter的机械族怪兽作为要放置到卡组最上面的卡。
	local g=Duel.SelectMatchingCard(tp,c23384666.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切我方卡组，使放置位置随机化后再将选中的卡放到卡组顶端。
		Duel.ShuffleDeck(tp)
		-- 将选中的卡片移动到卡组最上方（顶部）。
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 向双方玩家展示我方卡组最上方1张卡，确认放置的怪兽。
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 定义②效果的特殊召唤对象过滤函数：要求对象是机械族、攻击力与守备力相同，并且能够以表侧守备表示特殊召唤。
function c23384666.spfilter(c,e,tp)
	-- 判断对象为机械族且攻击力和守备力数值相同。
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件与选择目标函数：检查我方主要怪兽区是否有空位、墓地是否存在满足条件的机械族怪兽，并完成特殊召唤对象的选择。
function c23384666.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23384666.filter(chkc,e,tp) end
	-- 发动时检查我方主要怪兽区是否存在可用空格，以保证特殊召唤能进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足spfilter、且不是作为除外费用的这张卡自身（e:GetHandler()）的机械族怪兽可作为特殊召唤对象。
		and Duel.IsExistingTarget(c23384666.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的机械族怪兽，将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c23384666.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁操作信息：本效果将特殊召唤1只对象怪兽，供其他卡牌（如星尘龙等）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时的操作：若场上仍有空位且对象仍与效果关联，则将对象怪兽以表侧守备表示特殊召唤。
function c23384666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区有空位，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的对象怪兽（目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
