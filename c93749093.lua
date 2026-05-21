--マシュマカロン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地选这张卡以外的最多2只「马卡龙棉花糖」特殊召唤。
function c93749093.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地选这张卡以外的最多2只「马卡龙棉花糖」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93749093,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,93749093)
	e1:SetCondition(c93749093.spcon)
	e1:SetTarget(c93749093.sptg)
	e1:SetOperation(c93749093.spop)
	c:RegisterEffect(e1)
end
-- 判断是否因战斗或效果破坏而触发效果的条件函数
function c93749093.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：卡名为「马卡龙棉花糖」且可以被特殊召唤的怪兽
function c93749093.spfilter(c,e,tp)
	return c:IsCode(93749093) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查函数，确认怪兽区域有空位且手卡、卡组、墓地存在至少1只可以特殊召唤的「马卡龙棉花糖」
function c93749093.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1张除自身以外的「马卡龙棉花糖」
		and Duel.IsExistingMatchingCard(c93749093.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁处理的操作信息，表示此效果包含从手卡、卡组、墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数，从手卡、卡组、墓地选择最多2只「马卡龙棉花糖」特殊召唤
function c93749093.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 计算实际可以特殊召唤的最大数量，不能超过怪兽区域的可用空格数
	ct=math.min(ct,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ct<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1到ct张满足条件的「马卡龙棉花糖」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c93749093.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,ct,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
