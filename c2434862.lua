--方界降世
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。从卡组把1只「方界胤 毗贾姆」特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。从自己的手卡·卡组·墓地选1只「方界胤 毗贾姆」特殊召唤。只有对方场上才有怪兽存在的状态发动的场合，可以再选最多2只「方界胤 毗贾姆」特殊召唤。
function c2434862.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。从卡组把1只「方界胤 毗贾姆」特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2434862,0))  --"特殊召唤并转移攻击对象"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c2434862.condition)
	e1:SetTarget(c2434862.target)
	e1:SetOperation(c2434862.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。从自己的手卡·卡组·墓地选1只「方界胤 毗贾姆」特殊召唤。只有对方场上才有怪兽存在的状态发动的场合，可以再选最多2只「方界胤 毗贾姆」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2434862,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2434862)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c2434862.spcon)
	e2:SetTarget(c2434862.sptg)
	e2:SetOperation(c2434862.spop)
	c:RegisterEffect(e2)
end
-- 判断攻击方是否为对方
function c2434862.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp)
end
-- 过滤条件：卡名为「方界胤 毗贾姆」且可以特殊召唤
function c2434862.filter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件
function c2434862.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在「方界胤 毗贾姆」
		and Duel.IsExistingMatchingCard(c2434862.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：特殊召唤1只「方界胤 毗贾姆」并进行伤害计算
function c2434862.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「方界胤 毗贾姆」
	local g=Duel.SelectMatchingCard(tp,c2434862.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的卡特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前攻击的怪兽
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) then
			-- 进行伤害计算
			Duel.CalculateDamage(at,tc)
		end
	end
end
-- ②效果的发动条件：己方LP比对方少2000以上
function c2434862.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方LP是否比对方少2000以上
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
end
-- 判断是否满足②效果的发动条件
function c2434862.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡·卡组·墓地是否存在「方界胤 毗贾姆」
		and Duel.IsExistingMatchingCard(c2434862.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 判断是否为对方场上存在怪兽的状态
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理：特殊召唤1只「方界胤 毗贾姆」，若满足条件可再召唤最多2只
function c2434862.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只「方界胤 毗贾姆」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2434862.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()<=0 then return end
	-- 将选中的卡特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	ft=ft-1
	-- 获取手卡·卡组·墓地中的「方界胤 毗贾姆」
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c2434862.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if e:GetLabel()==1 and sg:GetCount()>0 and ft>0
		-- 询问是否继续特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(2434862,2)) then  --"是否继续特殊召唤？"
		-- 中断当前效果
		Duel.BreakEffect()
		ft=math.min(ft,sg:GetCount(),2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,ft,nil)
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
