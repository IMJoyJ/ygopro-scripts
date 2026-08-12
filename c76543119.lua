--ギミック・パペット－死の木馬
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，以场上1只「机关傀儡」怪兽为对象才能发动。那只怪兽破坏。
-- ②：这张卡从场上送去墓地时才能发动。从手卡把最多2只「机关傀儡」怪兽特殊召唤。
function c76543119.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，以场上1只「机关傀儡」怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76543119,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c76543119.target)
	e1:SetOperation(c76543119.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地时才能发动。从手卡把最多2只「机关傀儡」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76543119,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c76543119.spcon)
	e2:SetTarget(c76543119.sptg)
	e2:SetOperation(c76543119.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「机关傀儡」怪兽
function c76543119.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1083)
end
-- 效果①的发动准备：进行对象合法性检测，并选择场上1只「机关傀儡」怪兽作为对象，设置破坏操作信息
function c76543119.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c76543119.filter(chkc) end
	-- 在发动检测时，检查场上是否存在至少1只可以作为对象的表侧表示「机关傀儡」怪兽
	if chk==0 then return Duel.IsExistingTarget(c76543119.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示的「机关傀儡」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76543119.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理：获取对象怪兽，若其仍符合条件则将其破坏
function c76543119.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：检查这张卡是否是从场上送去墓地
function c76543119.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手牌中可以特殊召唤的「机关傀儡」怪兽
function c76543119.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自身怪兽区域是否有空位，且手牌中是否存在可特殊召唤的「机关傀儡」怪兽，并设置特殊召唤操作信息
function c76543119.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在至少1只可以特殊召唤的「机关傀儡」怪兽
		and Duel.IsExistingMatchingCard(c76543119.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手牌特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理：计算可特殊召唤的数量（受场地空位及青眼精灵龙等卡片效果限制），从手牌选择并特殊召唤最多2只「机关傀儡」怪兽
function c76543119.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1到ft张满足条件的「机关傀儡」怪兽
	local g=Duel.SelectMatchingCard(tp,c76543119.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
