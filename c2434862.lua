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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。从自己的手卡·卡组·墓地选1只「方界胤 毗贾姆」特殊召唤。只有对方场上才有怪兽存在的状态发动的场合，可以再选最多2只「方界胤 毗贾姆」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2434862,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2434862)
	-- 设置②效果的发动COST：把墓地中的这张卡除外（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c2434862.spcon)
	e2:SetTarget(c2434862.sptg)
	e2:SetOperation(c2434862.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：判断攻击宣言的怪兽为对方怪兽（攻击怪兽的控制者是对方）。
function c2434862.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp)
end
-- 特殊召唤候选卡的过滤条件：卡名必须为「方界胤 毗贾姆」，并且能够被当前效果特殊召唤（满足召唤条件和苏生限制）。
function c2434862.filter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动合法性检查：自己主要怪兽区存在空位，且卡组中存在可特殊召唤的「方界胤 毗贾姆」（不取对象）。
function c2434862.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的主要怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的「方界胤 毗贾姆」。
		and Duel.IsExistingMatchingCard(c2434862.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行特殊召唤的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选1只「方界胤 毗贾姆」特殊召唤；成功后，若攻击怪兽可攻击且不免疫此效果，强制其与特殊召唤的怪兽进行伤害计算（攻击对象转移）。
function c2434862.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己怪兽区有空位；若无空位则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张符合条件的「方界胤 毗贾姆」（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c2434862.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择并特殊召唤成功（返回不为0），进入后续处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前攻击宣言的怪兽。
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) then
			-- 让攻击怪兽与被特殊召唤的怪兽进行战斗伤害计算，实现攻击对象转移。
			Duel.CalculateDamage(at,tc)
		end
	end
end
-- ②效果的发动条件：自己基本分比对方少2000以上。
function c2434862.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己LP是否小于等于对方LP-2000（即少2000以上）。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
end
-- ②效果的发动合法性检查：自己怪兽区有空位，且手卡·卡组·墓地存在可特殊召唤的「方界胤 毗贾姆」。
function c2434862.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的主要怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地中是否存在至少1张满足条件的「方界胤 毗贾姆」。
		and Duel.IsExistingMatchingCard(c2434862.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 判断是否处于“只有对方场上才有怪兽存在的状态”：自己场上无怪兽且对方场上有怪兽。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 向系统登记本次效果将进行特殊召唤的操作信息：从手卡·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：先特殊召唤1只「方界胤 毗贾姆」；若满足“只有对方场上才有怪兽”且玩家选择继续，则再追加特殊召唤最多2只（实际数量受可用格子、候选数和青眼精灵龙效果限制）。
function c2434862.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1张符合条件的「方界胤 毗贾姆」（经王家长眠之谷过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2434862.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()<=0 then return end
	-- 将选中的第一只「方界胤 毗贾姆」以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	ft=ft-1
	-- 获取当前手卡·卡组·墓地中所有符合条件的「方界胤 毗贾姆」候选（经王家长眠之谷过滤），用于追加特殊召唤。
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c2434862.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if e:GetLabel()==1 and sg:GetCount()>0 and ft>0
		-- 询问玩家是否要继续进行追加特殊召唤（选择是则执行，否则结束）。
		and Duel.SelectYesNo(tp,aux.Stringid(2434862,2)) then  --"是否继续特殊召唤？"
		-- 中断当前效果处理，使后续追加特殊召唤作为独立的效果处理（错开时点）。
		Duel.BreakEffect()
		ft=math.min(ft,sg:GetCount(),2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 显示“请选择要特殊召唤的卡”的选择提示（追加特召时）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,ft,nil)
		-- 将选中的追加「方界胤 毗贾姆」特殊召唤到自己场上。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
