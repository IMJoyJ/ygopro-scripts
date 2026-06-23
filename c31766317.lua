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
	-- 场上存在的这张卡被破坏送去墓地时，可以选择「地狱女帝恶魔」以外的自己墓地存在的1只恶魔族·暗属性·6星以上的怪兽特殊召唤。
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
-- 过滤函数，用于检索满足条件的恶魔族·暗属性怪兽（可除外）
function c31766317.rfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 判断是否满足代替破坏的条件，包括：被破坏的怪兽是恶魔族·暗属性且在场上正面表示、不是自己、不是代替破坏原因、自己墓地存在可除外的恶魔族·暗属性怪兽
function c31766317.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=eg:GetFirst()
	if chk==0 then return eg:GetCount()==1 and dc~=e:GetHandler() and dc:IsFaceup() and dc:IsLocation(LOCATION_MZONE)
		and dc:IsRace(RACE_FIEND) and dc:IsAttribute(ATTRIBUTE_DARK) and not dc:IsReason(REASON_REPLACE)
		-- 检查自己墓地是否存在满足条件的恶魔族·暗属性怪兽
		and Duel.IsExistingMatchingCard(c31766317.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择1张满足条件的恶魔族·暗属性怪兽从墓地除外
		local g=Duel.SelectMatchingCard(tp,c31766317.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽从游戏中除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 判断场上存在的这张卡被破坏送去墓地时是否满足特殊召唤条件
function c31766317.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于检索满足条件的恶魔族·暗属性·6星以上的怪兽（可特殊召唤）
function c31766317.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(6)
		and not c:IsCode(31766317) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择函数，用于选择满足条件的恶魔族·暗属性·6星以上的怪兽
function c31766317.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31766317.filter(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件，包括：场上存在空位、自己墓地存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的恶魔族·暗属性·6星以上的怪兽
		and Duel.IsExistingTarget(c31766317.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张满足条件的恶魔族·暗属性·6星以上的怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c31766317.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c31766317.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
