--U.A.マン・オブ・ザ・マッチ
-- 效果：
-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：自己的「超级运动员」怪兽或者「方程式运动员」怪兽去用战斗破坏对方怪兽的伤害计算后或者去给与对方战斗伤害时才能发动。从自己的手卡·墓地选「超级运动员」怪兽以及「方程式运动员」怪兽任意数量守备表示特殊召唤（同名卡最多1张）。
function c48636108.initial_effect(c)
	-- 效果原文内容：①：自己的「超级运动员」怪兽或者「方程式运动员」怪兽去用战斗破坏对方怪兽的伤害计算后或者去给与对方战斗伤害时才能发动。从自己的手卡·墓地选「超级运动员」怪兽以及「方程式运动员」怪兽任意数量守备表示特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48636108,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCountLimit(1,48636108+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c48636108.spcon)
	e1:SetTarget(c48636108.sptg)
	e1:SetOperation(c48636108.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(48636108,1))  --"特殊召唤"
	e2:SetCondition(c48636108.spcon2)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
-- 效果作用：过滤出属于「超级运动员」或「方程式运动员」卡组的怪兽卡片。
function c48636108.filter(c)
	return c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER)
end
-- 效果作用：检查手卡或墓地中的「超级运动员」或「方程式运动员」怪兽是否可以特殊召唤。
function c48636108.spfilter(c,e,tp)
	return c48636108.filter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：判断是否满足发动条件，即己方的「超级运动员」或「方程式运动员」怪兽在战斗中破坏了对方怪兽。
function c48636108.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取此次战斗中的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 效果作用：获取此次战斗中的防守怪兽。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return c48636108.filter(a) and d:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果原文内容：①：自己的「超级运动员」怪兽或者「方程式运动员」怪兽去用战斗破坏对方怪兽的伤害计算后或者去给与对方战斗伤害时才能发动。从自己的手卡·墓地选「超级运动员」怪兽以及「方程式运动员」怪兽任意数量守备表示特殊召唤（同名卡最多1张）。
function c48636108.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and c48636108.filter(tc)
end
-- 效果作用：判断是否满足发动条件，即己方的「超级运动员」或「方程式运动员」怪兽在造成战斗伤害时。
function c48636108.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手卡或墓地中是否存在满足条件的「超级运动员」或「方程式运动员」怪兽。
		and Duel.IsExistingMatchingCard(c48636108.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：处理特殊召唤逻辑，包括获取可用区域数、筛选可特殊召唤的卡片组、检测青眼精灵龙限制并选择卡片进行特殊召唤。
function c48636108.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家当前场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果作用：从手卡和墓地中筛选出符合条件的「超级运动员」或「方程式运动员」怪兽卡片组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c48636108.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：根据选择条件筛选出满足要求的卡片子集。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 效果作用：将符合条件的卡片以守备表示形式特殊召唤到场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
