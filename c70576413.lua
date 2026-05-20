--DDD創始王クロヴィス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合，以自己的除外状态的1只「DD」怪兽为对象才能发动（场上有「契约书」卡存在的场合，也能作为代替从自己墓地作为对象）。那只怪兽特殊召唤。
-- ②：这张卡被除外的场合才能发动。这个回合中，自己的「DD」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括同调召唤手续、苏生限制、同调召唤成功时的特召效果，以及被除外时的赋予贯通效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己的除外状态的1只「DD」怪兽为对象才能发动（场上有「契约书」卡存在的场合，也能作为代替从自己墓地作为对象）。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。这个回合中，自己的「DD」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.eatg)
	e2:SetOperation(s.eaop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是通过同调召唤特殊召唤的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的「DD」怪兽：必须是除外状态表侧表示或墓地中的怪兽，且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xaf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤场上表侧表示的「契约书」卡片。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 效果①的发动准备：确定可选卡片的位置（默认除外，若场上有「契约书」则加上墓地），进行合法对象选择和空位检查。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_REMOVED
	-- 若场上存在表侧表示的「契约书」卡，则将可选卡片的位置范围扩大至包含墓地。
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then loc=loc+LOCATION_GRAVE end
	if chkc then return chkc:IsLocation(loc) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动准备检查：检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动准备检查：检查指定位置是否存在至少1只满足条件的「DD」怪兽可以作为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,loc,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只符合条件的「DD」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：包含特殊召唤分类，数量为1，对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的实际处理：获取选择的对象，在不受王家之谷影响且卡片仍存在于对应区域时，将其特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个（也是唯一一个）效果对象。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与当前连锁有关联，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动准备：检查本回合是否尚未注册该效果的标识（确保同一回合内该效果只适用一次）。
function s.eatg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动准备检查：检查玩家本回合是否尚未注册过该效果的标识。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 效果②的实际处理：给玩家注册回合结束前有效的标识，并注册一个全局效果，使自己场上的「DD」怪兽在攻击守备表示怪兽时获得贯通战斗伤害的效果。
function s.eaop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册一个持续到回合结束的标识，用于标记该效果在本回合已适用。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 这个回合中，自己的「DD」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将贯通效果作为玩家的效果注册到全局环境中。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤受贯通效果影响的怪兽：必须是「DD」怪兽。
function s.tg(e,c)
	return c:IsSetCard(0xaf)
end
