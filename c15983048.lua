--大魔鍵－マフテアル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次，把这张卡作为同调·超量召唤的素材的场合，不是「魔键」怪兽的同调·超量召唤不能使用。
-- ①：自己场上有「魔键」怪兽存在的场合，把手卡的这张卡给对方观看才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「魔键」怪兽召唤。
-- ②：这张卡召唤成功时，以自己墓地的4星以下的1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c15983048.initial_effect(c)
	-- 对应效果原文：把这张卡作为同调·超量召唤的素材的场合，不是「魔键」怪兽的同调·超量召唤不能使用。（本段实现同调素材限制部分）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c15983048.matlimit)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：自己场上有「魔键」怪兽存在的场合，把手卡的这张卡给对方观看才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「魔键」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15983048,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c15983048.condition)
	e2:SetCost(c15983048.cost)
	e2:SetTarget(c15983048.target)
	e2:SetOperation(c15983048.operation)
	c:RegisterEffect(e2)
	-- 对应效果原文：这个卡名的②的效果1回合只能使用1次。②：这张卡召唤成功时，以自己墓地的4星以下的1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
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
-- 作为同调/超量素材限制的判定函数：若素材不是「魔键」怪兽，则返回 true 表示该卡不能作为这张卡的同调/超量素材。
function c15983048.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x165)
end
-- 过滤函数：筛选自己场上表侧表示且属于「魔键」系列的怪兽。
function c15983048.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x165)
end
-- ①效果的发动条件判断：自己场上是否存在表侧表示的「魔键」怪兽。
function c15983048.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「魔键」怪兽，作为发动①效果的前提条件。
	return Duel.IsExistingMatchingCard(c15983048.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动代价判定：这张卡必须处于手卡且非公开状态，即需要向对方展示手卡的这张卡作为代价。
function c15983048.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果的发动目标合法检查：确认玩家本回合可以进行通常召唤、拥有追加召唤次数，且本回合尚未使用过此卡名①效果。
function c15983048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前可以进行通常召唤，并且还拥有通常召唤外的追加召唤次数。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查该卡名的①效果在本回合尚未发动过（用标记防止重复发动）。
		and Duel.GetFlagEffect(tp,15983048)==0 end
end
-- ①效果处理：为玩家赋予一次追加的通常召唤机会，仅限召唤「魔键」怪兽，并标记本回合已使用过①效果。
function c15983048.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：这个回合，自己在通常召唤外加上只有1次，可以把1只「魔键」怪兽召唤。②：这张卡召唤成功时，以自己墓地的4星以下的1只通常怪兽或者「魔键」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(15983048,2))  --"使用「大魔键-马夫提亚尔」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 将追加召唤效果的对象限定为手牌或场上的「魔键」怪兽，只有这类怪兽能享受额外召唤次数。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x165))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该追加召唤效果注册到当前玩家，使其在本回合内实际生效。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个本回合的标记，防止同名①效果重复使用。
	Duel.RegisterFlagEffect(tp,15983048,RESET_PHASE+PHASE_END,0,1)
end
-- ②效果的对象过滤器：选择自己墓地中等级4以下、且为通常怪兽或「魔键」怪兽，并能被特殊召唤的卡。
function c15983048.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件与取对象处理：确认场上有空位且墓地存在符合条件的对象，并允许选择1张墓地中的卡作为对象。
function c15983048.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c15983048.spfilter(chkc,e,tp) end
	-- 发动②效果前确认自己场上存在可以特殊召唤怪兽的格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1张满足条件且能够被特殊召唤的「魔键」怪兽或4星以下的通常怪兽。
		and Duel.IsExistingTarget(c15983048.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，要求选择要特殊召唤的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合条件的怪兽卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c15983048.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，告知系统本次效果将进行特殊召唤，对象为已选择的墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将作为对象的墓地怪兽以表侧守备表示特殊召唤到自己场上。
function c15983048.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上（需满足召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
