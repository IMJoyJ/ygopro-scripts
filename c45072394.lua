--鉄の檻
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上1只怪兽送去墓地。场地区域有「急流山的金宫」存在的场合，也能作为代替把对方场上的怪兽送去墓地。
-- ②：自己准备阶段，以这张卡的①的效果送去自己或者对方的墓地的1只怪兽为对象才能发动。这张卡破坏，那只怪兽在自己场上特殊召唤。
function c45072394.initial_effect(c)
	-- 将「急流山的金宫」的卡号72283691登记为这张卡记载的关联卡名，使系统能识别这张卡与「急流山的金宫」的关系。
	aux.AddCodeList(c,72283691)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，自己场上1只怪兽送去墓地。场地区域有「急流山的金宫」存在的场合，也能作为代替把对方场上的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45072394+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c45072394.target)
	e1:SetOperation(c45072394.operation)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段，以这张卡的①的效果送去自己或者对方的墓地的1只怪兽为对象才能发动。这张卡破坏，那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45072394,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45072394.spcon)
	e2:SetTarget(c45072394.sptg)
	e2:SetOperation(c45072394.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 发动时的合法检查：从可送墓范围（自己怪兽区；若金宫在场则对方怪兽区也可选）确认至少存在1只可以送去墓地的怪兽，以确保效果处理时能够执行送墓。
function c45072394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	-- 检测场地区是否存在「急流山的金宫」（任意玩家控制），若存在则将送墓对象范围扩大到对方场上。
	if Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) then
		loc=LOCATION_MZONE
	end
	-- 效果发动条件判定：在可选范围内（自己怪兽区，若金宫存在则含对方怪兽区）是否至少有1张能送去墓地的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,loc,1,nil) end
end
-- 效果处理：根据金宫存在情况确定可选范围，提示玩家选择1只怪兽送去墓地；若送墓成功且该怪兽仍在墓地，则给它标记45072394，并将其记录在e1的LabelObject中，用于②效果检索。
function c45072394.operation(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	-- 效果处理时再次检查场地区是否存在「急流山的金宫」，以决定是否可将对方怪兽作为送墓对象。
	if Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) then
		loc=LOCATION_MZONE
	end
	-- 给玩家弹出选择提示，要求选择1只要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从合法范围（自己怪兽区，若金宫存在则包含对方怪兽区）选择1张能送去墓地的怪兽卡；此选择不取对象，在效果处理时进行。
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,loc,1,1,nil):GetFirst()
	-- 若选择了怪兽且将其成功送去墓地，并且该怪兽现在位于墓地，则对该怪兽设置45072394标记并记录到效果中，确认它是被①效果送墓的卡。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		tc:RegisterFlagEffect(45072394,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
	end
end
-- ②效果的发动条件：必须是自己回合的准备阶段（当前回合玩家是这张卡的控制者）。
function c45072394.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，即只有自己的准备阶段才能发动②效果。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的对象过滤函数：判断候选怪兽必须是此前被①效果送去墓地的那只怪兽（通过比较e2的LabelObject中的e1的LabelObject，以及45072394标记），并且它能够被当前效果特殊召唤。
function c45072394.filter(c,e,tp)
	return c==e:GetLabelObject():GetLabelObject() and c:GetFlagEffect(45072394)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与取对象：确认自己主要怪兽区有空位，并检查墓地存在满足过滤条件的怪兽，满足则选择1只作为对象。
function c45072394.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c45072394.filter(chkc,e,tp) end
	-- 检查自己的主要怪兽区是否至少有1个空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足过滤条件并能成为效果对象的怪兽（取对象效果的合法性检查）。
		and Duel.IsExistingTarget(c45072394.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 给玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只符合条件且可特殊召唤的怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c45072394.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 将“破坏这张卡”的操作信息写入当前连锁，使系统能识别破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 将“特殊召唤对象怪兽”的操作信息写入当前连锁，使系统能识别特殊召唤效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果实际处理：若这张卡仍在场上且连锁有效，先将其破坏；若破坏成功且对象怪兽仍未被移走，则将对象怪兽表侧表示特殊召唤到自己场上。
function c45072394.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽（墓地中的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 处理条件判断：这张卡仍然有效且能够被破坏，破坏这张卡成功，且对象怪兽仍然与效果相关（未被除外等情况），才继续特殊召唤。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（需检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
