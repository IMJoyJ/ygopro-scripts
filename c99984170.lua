--RESCUE！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「救援ACE队」怪兽为对象才能发动（自己场上有「救援ACE队 消防栓」存在的场合，也能作为代替以对方墓地1只怪兽为对象）。那只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：设置效果描述、分类为特殊召唤、类型为魔法卡发动、发动时点为自由时点、取对象属性、提示时点、同名卡1回合1次的发动次数限制，并指定发动时选择目标和效果处理的函数，最后注册到卡片上。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「救援ACE队」怪兽为对象才能发动（自己场上有「救援ACE队 消防栓」存在的场合，也能作为代替以对方墓地1只怪兽为对象）。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的怪兽过滤条件：该怪兽必须能被特殊召唤；若自己场上有「救援ACE队 消防栓」（check为真），则允许选择对方墓地的怪兽，否则只能选择自己墓地的「救援ACE队」系列怪兽（系列编号0x18b）。
function s.spfilter(c,e,tp,check)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (check and c:IsControler(1-tp) or c:IsSetCard(0x18b) and c:IsControler(tp))
end
-- 检查场上是否存在正面表示的「救援ACE队 消防栓」（卡号37617348），用于判断是否可将选择对象扩大到对方墓地。
function s.checkfilter(c)
	return c:IsCode(37617348) and c:IsFaceup()
end
-- 发动时的目标处理：先检查自己场上是否有消防栓；若在连锁验证对象时，检查chkc是否位于墓地且满足spfilter；效果发动条件为自己主要怪兽区有空位，且墓地存在至少1只满足spfilter的怪兽（check决定是否包含对方墓地）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在正面表示的「救援ACE队 消防栓」（卡号37617348），并将结果存入check变量。
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,check) end
	-- 效果发动合法性判定之一：自己场上主要怪兽区存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动合法性判定之二：根据check条件，在相应墓地范围内存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,check) end
	-- 给玩家弹出选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地中选择1只满足过滤条件（spfilter）的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,check)
	-- 登记本次连锁的特殊召唤操作信息，指定要特殊召唤的对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得发动时选择的目标，若目标仍与该效果关联，则将其特殊召唤到自己场上。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
