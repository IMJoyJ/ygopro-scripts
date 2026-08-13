--U.A.マン・オブ・ザ・マッチ
-- 效果：
-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：自己的「超级运动员」怪兽或者「方程式运动员」怪兽去用战斗破坏对方怪兽的伤害计算后或者去给与对方战斗伤害时才能发动。从自己的手卡·墓地选「超级运动员」怪兽以及「方程式运动员」怪兽任意数量守备表示特殊召唤（同名卡最多1张）。
function c48636108.initial_effect(c)
	-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。①：自己的「超级运动员」怪兽或者「方程式运动员」怪兽去用战斗破坏对方怪兽的伤害计算后或者去给与对方战斗伤害时才能发动。从自己的手卡·墓地选「超级运动员」怪兽以及「方程式运动员」怪兽任意数量守备表示特殊召唤（同名卡最多1张）。
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
-- 检查卡片是否为「超级运动员」（0xb2）或「方程式运动员」（0x107）字段的怪兽卡。
function c48636108.filter(c)
	return c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER)
end
-- 判断怪兽是否属于上述系列，且能够以表侧守备表示特殊召唤（同时检查召唤条件与苏生限制）。
function c48636108.spfilter(c,e,tp)
	return c48636108.filter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果1的发动条件（伤害计算后）：若自己的「超级运动员」/「方程式运动员」怪兽战斗破坏对方怪兽，则满足条件；若攻击方为对方则交换攻击者与攻击对象后再判定。
function c48636108.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击对象（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return c48636108.filter(a) and d:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果2的发动条件（战斗伤害）：给与对方战斗伤害时，造成伤害的怪兽为自己的「超级运动员」/「方程式运动员」怪兽则满足条件。
function c48636108.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and c48636108.filter(tc)
end
-- 效果1的发动时点处理：在chk==0时检查己方怪兽区是否有空位、手卡/墓地是否有可特殊召唤的系列怪兽；两者满足才允许发动。
function c48636108.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的确认条件之一：己方主要怪兽区域存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动的确认条件之二：手卡·墓地存在至少1只符合特殊召唤条件的「超级运动员」/「方程式运动员」怪兽。
		and Duel.IsExistingMatchingCard(c48636108.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次连锁的处理信息为特殊召唤（CATEGORY_SPECIAL_SUMMON）；因实际特殊召唤的卡数和来源在处理时才能确定，targets设为nil，count暂记1，target_player为自己，位置参数为LOCATION_DECK。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：从手卡/墓地筛选可特殊召唤的系列怪兽（并应用王家长眠之谷过滤），若无空格或候选则结束；若「青眼精灵龙」效果适用则限制最多特召1只；随后由玩家选择卡名互不相同的1至上限张怪兽，以表侧守备表示特殊召唤到自己场上。
function c48636108.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方当前可用的主要怪兽区域空格数，作为本次可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 从手卡·墓地中筛选出可特殊召唤的系列怪兽，并用aux.NecroValleyFilter排除受王家长眠之谷影响而无法作为效果的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c48636108.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选取1至ft张卡片，要求所选卡片的卡名互不相同（同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选中的卡片以表侧守备表示特殊召唤到己方场上（sumtype=0，并检查召唤条件与苏生限制）。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
