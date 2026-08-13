--マギステル・オブ・エンディミオン
-- 效果：
-- ←8 【灵摆】 8→
-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把这张卡3个魔力指示物取除才能发动。自己的额外卡组1只表侧表示的可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
-- 【怪兽效果】
-- 自己对「恩底弥翁的统领」1回合只能有1次特殊召唤。
-- ①：这张卡的攻击宣言时才能发动。给这张卡放置1个魔力指示物。
-- ②：对方回合1次，把自己场上3个魔力指示物取除才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
function c66104644.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE+LOCATION_MZONE)
	-- 为这张卡添加灵摆怪兽属性，使其可以在灵摆区域发动并适用灵摆召唤规则。
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(66104644)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	-- 注册连锁发生的辅助处理：在连锁发生（魔法卡发动）时记录这张卡在场上存在，供后续连锁处理结束时判断放置指示物。
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c66104644.counterop)
	c:RegisterEffect(e2)
	-- ②：把这张卡3个魔力指示物取除才能发动。自己的额外卡组1只表侧表示的可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66104644,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCost(c66104644.spcost)
	e3:SetTarget(c66104644.sptg)
	e3:SetOperation(c66104644.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡的攻击宣言时才能发动。给这张卡放置1个魔力指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66104644,1))  --"放置指示物"
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetTarget(c66104644.countertg2)
	e4:SetOperation(c66104644.counterop2)
	c:RegisterEffect(e4)
	-- ②：对方回合1次，把自己场上3个魔力指示物取除才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66104644,2))  --"取除指示物从卡组特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetCondition(c66104644.spcon2)
	e5:SetCost(c66104644.spcost2)
	e5:SetTarget(c66104644.sptg2)
	e5:SetOperation(c66104644.spop2)
	c:RegisterEffect(e5)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(66104644,1))  --"放置指示物"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c66104644.pencon)
	e6:SetTarget(c66104644.pentg)
	e6:SetOperation(c66104644.penop)
	c:RegisterEffect(e6)
	-- ③：那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD_P)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetOperation(c66104644.regop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
end
c66104644.mentioned_counter={
	[0x1]=true,
}
-- 效果处理：若这次连锁是魔法卡的卡的发动，且连锁发生时这张卡在场上存在，则给这张卡放置1个魔力指示物。
function c66104644.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 发动代价：检查并取除这张卡的3个魔力指示物。
function c66104644.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 筛选器：选出表侧表示、可以放置魔力指示物、能放置1个魔力指示物、可以特殊召唤且有可供其出场的空位的额外卡组怪兽。
function c66104644.spfilter(c,e,tp)
	-- 筛选条件：这张卡是表侧表示、可以放置魔力指示物，且当前能向其放置1个魔力指示物。
	return c:IsFaceup() and c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 筛选条件：这张卡可以特殊召唤，且场上有可供其从额外卡组出场的空格。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动条件检查：自己怪兽区至少有1个空位、可使用的怪兽区足够同时召唤2只且「青眼精灵龙」效果未生效、这张卡可以特殊召唤并能放置指示物、额外卡组存在满足条件的怪兽。
function c66104644.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的怪兽区域至少有1个可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetUsableMZoneCount(tp)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查这张卡可以特殊召唤，且当前能向其放置1个魔力指示物。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查自己的额外卡组存在至少1只满足筛选条件的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c66104644.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将特殊召唤包含这张卡在内的2只怪兽，其中1只来自额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
-- 效果处理：处理时重新确认怪兽区空位及「青眼精灵龙」的限制，不满足则中断处理。
function c66104644.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次检查自己的怪兽区域是否还有可用的空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.GetUsableMZoneCount(tp)<1 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 向玩家提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组选择1只满足筛选条件的表侧表示怪兽。
	local g=Duel.SelectMatchingCard(tp,c66104644.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的额外卡组怪兽以表侧表示特殊召唤（特殊召唤步骤）。
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		-- 将灵摆区域的这张卡以表侧表示特殊召唤（特殊召唤步骤）。
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		-- 结束特殊召唤步骤，完成这次同时特殊召唤的处理。
		Duel.SpecialSummonComplete()
		g:AddCard(c)
		-- 依次遍历这2只特殊召唤成功的怪兽，给每只各放置1个魔力指示物。
		for tc in aux.Next(g) do
			tc:AddCounter(0x1,1)
		end
	end
end
-- 目标检查：确认这张卡可以放置1个魔力指示物，并设置指示物放置的操作信息。
function c66104644.countertg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x1,1) end
	-- 设置操作信息：本次连锁将给卡放置1个指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果处理：给这张卡放置1个魔力指示物。
function c66104644.counterop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 发动条件：只有在对方回合才能发动。
function c66104644.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方（非自己）。
	return Duel.GetTurnPlayer()==1-tp
end
-- 发动代价：检查并把自己场上的3个魔力指示物取除。
function c66104644.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够可因代价取除的3个魔力指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 把自己场上的3个魔力指示物作为发动代价取除。
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 筛选器：选出可以放置魔力指示物且可以特殊召唤的怪兽。
function c66104644.spfilter2(c,e,tp)
	return c:IsCanHaveCounter(0x1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查：自己怪兽区有空位，且卡组存在可以放置魔力指示物、可以特殊召唤的怪兽。
function c66104644.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的怪兽区域有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组存在至少1只满足筛选条件的怪兽。
		and Duel.IsExistingMatchingCard(c66104644.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将从自己的卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1只可以放置魔力指示物的怪兽，并将其特殊召唤。
function c66104644.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组选择1只满足筛选条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,c66104644.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的怪兽从卡组以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动条件：这张卡被破坏前在怪兽区域存在且为表侧表示。
function c66104644.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 目标检查：确认自己的灵摆区域有空位可以放置这张卡。
function c66104644.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的左端或右端是否有可用的空格。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果处理：若这张卡仍与该效果相关，则把这张卡放置到自己的灵摆区域，之后放置之前记录数量的魔力指示物。
function c66104644.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 确认这张卡与该效果相关并将其以表侧表示移动到自己的灵摆区域。
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 离场前处理：记录这张卡离场时放置的魔力指示物数量，作为被破坏效果的指示物放置数量。
function c66104644.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetCounter(0x1))
end
