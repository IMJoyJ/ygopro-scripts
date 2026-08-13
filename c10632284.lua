--ミメシスエレファント
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡发动后变成效果怪兽（兽族·地·2星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ②：这张卡在怪兽区域存在的场合，自己·对方回合，宣言种族和属性各1个，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族·属性。
local s,id,o=GetID()
-- 初始化效果的入口，为拟态象依次注册①的陷阱发动后作为效果怪兽特殊召唤的效果，以及②的怪兽区域可发动的宣言种族属性并改变对象种族属性的二速效果。
function s.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（兽族·地·2星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的场合，自己·对方回合，宣言种族和属性各1个，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族·属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(s.artg)
	e2:SetOperation(s.arop)
	c:RegisterEffect(e2)
end
-- 发动条件检查：确认无额外代价/前置条件遗漏、自己主要怪兽区有空位，并且能够将拟态象作为效果怪兽（兽族·地·2星·攻0/守2000）特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区是否存在可用空格，用于后续特殊召唤这只陷阱怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否被允许特殊召唤拟态象（以效果陷阱怪兽的身份，种族兽、属性地、2星、攻0守2000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,2,RACE_BEAST,ATTRIBUTE_EARTH) end
	-- 设定连锁处理信息：本次效果包含将这张卡自身特殊召唤1只到场上，类别为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：再次确认能够特殊召唤后，将这张卡变为效果怪兽（同时视为陷阱卡），并以表侧攻击表示特殊召唤到己方主要怪兽区。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理阶段再次检测特殊召唤是否仍被允许；若不允许则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,2,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以表侧攻击表示特殊召唤到己方怪兽区域；nocheck=true表示不检查召唤条件，nolimit=false表示仍受苏生限制约束。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
-- 目标筛选条件：选择场上表侧表示怪兽，且该怪兽未同时拥有所宣言的种族和属性，避免无效变更。
function s.filter(c,r,a)
	return c:IsFaceup() and not (c:IsRace(r) and c:IsAttribute(a))
end
-- ②效果发动处理：先确认取对象的目标合法且场上存在可选的表侧表示怪兽；由玩家宣言1个种族和1个属性并暂存到效果标签；再选择1只场上表侧表示怪兽作为效果对象。
function s.artg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e:GetLabel()) end
	-- 检查场上是否存在1只表侧表示怪兽可以作为此效果的取对象目标。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出种族选择提示，让玩家从全种族中宣言1个种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 由操作玩家在全部种族中宣言1个种族，返回值作为要变更的种族值。
	local rac=Duel.AnnounceRace(tp,1,RACE_ALL)
	-- 弹出属性选择提示，让玩家从全部属性中宣言1个属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 由操作玩家在全部属性中宣言1个属性，返回值作为要变更的属性值。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(rac,att)
	-- 弹出选择提示，让玩家选择1只场上表侧表示怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方场上表侧表示且满足过滤条件的怪兽中选择1只，作为本效果的对象并记录到当前连锁。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽；若目标仍表侧表示且与本效果相关联，则给它分别注册改变种族和改变属性的效果，使其种族和属性变为宣言值，直到回合结束时生效。
function s.arop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local r,a=e:GetLabel()
		-- 那只怪兽直到回合结束时变成宣言的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(r)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽直到回合结束时变成宣言的属性
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(a)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
