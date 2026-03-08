--クリボルト
-- 效果：
-- 自己的主要阶段时，选择持有超量素材的1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，从自己卡组把1只「电击栗子」特殊召唤。这张卡不能作为同调素材。
function c40817915.initial_effect(c)
	-- 效果原文：自己的主要阶段时，选择持有超量素材的1只超量怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40817915,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40817915.target)
	e1:SetOperation(c40817915.activate)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 规则层面：过滤满足条件的怪兽（正面表示且有超量素材）
function c40817915.ofilter(c)
	return c:IsFaceup() and c:GetOverlayCount()~=0
end
-- 规则层面：过滤满足条件的「电击栗子」（卡号40817915且可特殊召唤）
function c40817915.spfilter(c,e,tp)
	return c:IsCode(40817915) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：判断是否满足发动条件（有空场、有目标怪兽、卡组有电击栗子）
function c40817915.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40817915.ofilter(chkc) end
	-- 规则层面：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断场上是否存在持有超量素材的怪兽
		and Duel.IsExistingTarget(c40817915.ofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 规则层面：判断卡组是否存在可特殊召唤的电击栗子
		and Duel.IsExistingMatchingCard(c40817915.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 规则层面：提示玩家选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 规则层面：选择目标怪兽（持有超量素材的1只怪兽）
	local g=Duel.SelectTarget(tp,c40817915.ofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面：设置操作信息（将要特殊召唤1只电击栗子）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：处理效果发动后的操作（取除超量素材并特殊召唤电击栗子）
function c40817915.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:GetOverlayCount()==0 then return end
	tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 规则层面：判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：从卡组选择1只电击栗子
	local g=Duel.SelectMatchingCard(tp,c40817915.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面：将选中的电击栗子特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
