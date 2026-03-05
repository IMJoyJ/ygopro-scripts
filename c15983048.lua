--大魔鍵－マフテアル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次，把这张卡作为同调·超量召唤的素材的场合，不是「魔键」怪兽的同调·超量召唤不能使用。
-- ①：自己场上有「魔键」怪兽存在的场合，把手卡的这张卡给对方观看才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「魔键」怪兽召唤。
-- ②：这张卡召唤成功时，以自己墓地的4星以下的1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c15983048.initial_effect(c)
	-- 效果原文：这个卡名的②的效果1回合只能使用1次，把这张卡作为同调·超量召唤的素材的场合，不是「魔键」怪兽的同调·超量召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c15983048.matlimit)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己场上有「魔键」怪兽存在的场合，把手卡的这张卡给对方观看才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「魔键」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15983048,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c15983048.condition)
	e2:SetCost(c15983048.cost)
	e2:SetTarget(c15983048.target)
	e2:SetOperation(c15983048.operation)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡召唤成功时，以自己墓地的4星以下的1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15983048,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,15983048)
	e3:SetTarget(c15983048.sptg)
	e3:SetOperation(c15983048.spop)
	c:RegisterEffect(e3)
end
-- 规则层面：设置该卡不能作为同调素材，除非是「魔键」怪兽
function c15983048.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x165)
end
-- 规则层面：过滤场上存在的「魔键」怪兽
function c15983048.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x165)
end
-- 规则层面：检查自己场上是否存在「魔键」怪兽
function c15983048.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查自己场上是否存在「魔键」怪兽
	return Duel.IsExistingMatchingCard(c15983048.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面：检查手牌是否已经公开
function c15983048.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 规则层面：检查玩家是否可以通常召唤、是否可以额外召唤且未使用过①效果
function c15983048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家是否可以通常召唤
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 规则层面：检查是否已使用过①效果
		and Duel.GetFlagEffect(tp,15983048)==0 end
end
-- 规则层面：注册一个使玩家可以额外召唤一次「魔键」怪兽的效果
function c15983048.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：①：自己场上有「魔键」怪兽存在的场合，把手卡的这张卡给对方观看才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「魔键」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(15983048,2))  --"使用「大魔键-马夫提亚尔」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 规则层面：设置该效果仅对「魔键」怪兽生效
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x165))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面：将该效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 规则层面：注册一个标识效果，防止①效果重复使用
	Duel.RegisterFlagEffect(tp,15983048,RESET_PHASE+PHASE_END,0,1)
end
-- 规则层面：过滤墓地中的4星以下的通常怪兽或「魔键」怪兽
function c15983048.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面：检查是否有满足条件的怪兽可特殊召唤
function c15983048.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c15983048.spfilter(chkc,e,tp) end
	-- 规则层面：检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查是否有满足条件的怪兽可特殊召唤
		and Duel.IsExistingTarget(c15983048.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择目标怪兽
	local g=Duel.SelectTarget(tp,c15983048.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面：设置连锁操作信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面：执行特殊召唤操作
function c15983048.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面：将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
