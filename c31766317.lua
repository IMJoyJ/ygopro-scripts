--ヘル・エンプレス・デーモン
-- 效果：
-- 这张卡以外的场上表侧表示存在的恶魔族·暗属性怪兽1只被破坏的场合，可以作为代替把自己墓地存在的1只恶魔族·暗属性怪兽从游戏中除外。此外，场上存在的这张卡被破坏送去墓地时，可以选择「地狱女帝恶魔」以外的自己墓地存在的1只恶魔族·暗属性·6星以上的怪兽特殊召唤。
function c31766317.initial_effect(c)
	-- 这张卡以外的场上表侧表示存在的恶魔族·暗属性怪兽1只被破坏的场合，可以作为代替把自己墓地存在的1只恶魔族·暗属性怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c31766317.destg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 此外，场上存在的这张卡被破坏送去墓地时，可以选择「地狱女帝恶魔」以外的自己墓地存在的1只恶魔族·暗属性·6星以上的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31766317,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c31766317.spcon)
	e2:SetTarget(c31766317.sptg)
	e2:SetOperation(c31766317.spop)
	c:RegisterEffect(e2)
end
-- 过滤出自己墓地中种族为恶魔族、属性为暗属性、且可以被除外的怪兽，作为代替破坏时除外的候选卡。
function c31766317.rfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 代替破坏效果的条件判定：本次被破坏的卡必须只有1只，不是这张卡，且是表侧表示存在于主要怪兽区的恶魔族暗属性怪兽，并且不是被其他代替破坏效果处理导致破坏的；同时自己墓地存在可除外的恶魔族暗属性怪兽，才能发动代替破坏。
function c31766317.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=eg:GetFirst()
	if chk==0 then return eg:GetCount()==1 and dc~=e:GetHandler() and dc:IsFaceup() and dc:IsLocation(LOCATION_MZONE)
		and dc:IsRace(RACE_FIEND) and dc:IsAttribute(ATTRIBUTE_DARK) and not dc:IsReason(REASON_REPLACE)
		-- 追加检查自己墓地是否存在至少1张满足rfilter条件的恶魔族暗属性怪兽，即可否支付代替破坏所需的除外代价。
		and Duel.IsExistingMatchingCard(c31766317.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹窗询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 给玩家显示选择要除外的卡片的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从自己墓地选择1张满足rfilter条件的恶魔族暗属性怪兽，作为代替破坏而除外的卡。
		local g=Duel.SelectMatchingCard(tp,c31766317.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的那张墓地怪兽表侧表示除外，完成代替破坏的处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 诱发条件：这张卡被破坏（REASON_DESTROY），并且破坏前位于场上（LOCATION_ONFIELD），即“场上存在的这张卡被破坏送去墓地时”。
function c31766317.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选特殊召唤对象：自己墓地的恶魔族、暗属性、6星以上怪兽，且不是「地狱女帝恶魔」自身，并且能够被当前效果特殊召唤。
function c31766317.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(6)
		and not c:IsCode(31766317) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标处理：检查对象卡是否合法；发动时确认自己主要怪兽区有空位，并且墓地存在满足条件的对象；然后进入选择对象阶段。
function c31766317.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31766317.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区域，以确定能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张可以成为特殊召唤对象且满足filter条件的恶魔族暗属性6星以上怪兽。
		and Duel.IsExistingTarget(c31766317.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示选择要特殊召唤的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1张满足filter条件的恶魔族暗属性6星以上怪兽，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c31766317.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，宣告本次效果将对选择的怪兽进行特殊召唤，供其他卡片效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理：取得对象卡，确认其仍与效果关联后，将其特殊召唤到场上。
function c31766317.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动特殊召唤效果时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己的主要怪兽区，完成特殊召唤处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
