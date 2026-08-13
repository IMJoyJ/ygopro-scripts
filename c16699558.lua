--藍眼の銀龍
-- 效果：
-- 龙族8星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。对方场上的全部表侧表示卡的效果无效化。
-- ②：没有通常怪兽在作为超量素材中的这张卡不能直接攻击。
-- ③：把这张卡1个超量素材取除，以自己的墓地·除外状态的1只通常怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 初始化函数：为蓝眼银龙添加超量召唤手续，并注册①（超量召唤成功时无效对方全场表侧卡效果）、②（无通常素材时不能直接攻击）、③（取除素材特殊召唤墓地和除外状态的通常怪兽并加攻）三个效果。
function s.initial_effect(c)
	-- 添加XYZ召唤手续：以2只龙族8星怪兽为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),8,2)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡超量召唤的场合才能发动。对方场上的全部表侧表示卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：没有通常怪兽在作为超量素材中的这张卡不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(s.dircon)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：把这张卡1个超量素材取除，以自己的墓地·除外状态的1只通常怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡是超量召唤成功时（通过IsSummonType(SUMMON_TYPE_XYZ)判断），只有超量召唤的场合才能发动。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果的发动目标与处理信息：检查对方场上是否存在可无效化的表侧表示卡，若有则将对方场上全部可无效化的表侧表示卡登记为无效化对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：对方场上有至少1张可无效化的表侧表示卡时才可发动（不取对象）。chk==0表示发动合法性检查阶段。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上当前全部可无效化的表侧表示卡（用于后续无效化）。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将上述卡片组g整体作为无效化处理对象，数量为g的卡片张数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果处理：将对方场上所有可无效化的表侧表示卡逐一赋予无效化效果：EFFECT_DISABLE（怪兽效果无效）和EFFECT_DISABLE_EFFECT（效果无效），若为陷阱怪兽则额外赋予陷阱怪兽无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理时重新获取对方场上全部可无效化的表侧表示卡（与发动时取得的一致）。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 遍历卡片组g中的每一张卡，对每张卡进行无效化处理。
	for tc in aux.Next(g) do
		-- 对方场上的全部表侧表示卡的效果无效化（赋予EFFECT_DISABLE，使卡无效化）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示卡的效果无效化（赋予EFFECT_DISABLE_EFFECT，使卡的效果无效化）。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对方场上的全部表侧表示卡的效果无效化（若该卡是陷阱怪兽，则额外使其陷阱怪兽效果无效化）。
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- ②的适用条件：这张卡的超量素材中没有通常怪兽（FilterCount(TYPE_NORMAL)==0）时，不能直接攻击。
function s.dircon(e)
	return e:GetHandler():GetOverlayGroup():FilterCount(Card.IsType,nil,TYPE_NORMAL)==0
end
-- ③的发动代价：取除这张卡1个超量素材（作为COST），检查阶段用CheckRemoveOverlayCard确认可取除。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象筛选条件：从自己墓地·除外状态选择1只表侧表示的通常怪兽，并且该怪兽能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③发动时的目标选择：先确认我方主要怪兽区有空位且存在满足条件的通常怪兽；然后选择其中1只作为对象（chkc用于对象合法性确认）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件判定：我方主要怪兽区有可用空格（Duel.GetLocationCount>0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地·除外状态中存在1只满足s.spfilter条件的通常怪兽作为对象（IsExistingTarget确认可成为对象）。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地·除外状态选择1只满足条件的通常怪兽，并同时将其登记为当前效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的1张卡作为特殊召唤处理对象（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：若对象仍与效果相关且不受王家长眠之谷影响，则将其表侧表示特殊召唤，并使其攻击力上升1000；最后调用SpecialSummonComplete完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得③效果选择的对象卡（第一张，也是唯一一张）。
	local tc=Duel.GetFirstTarget()
	-- 判断并执行特殊召唤：对象仍与效果相关、不受王家长眠之谷影响，且通过Duel.SpecialSummonStep成功进行表侧表示特殊召唤时，才触发后续加攻。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理，触发特殊召唤成功时的时点。
	Duel.SpecialSummonComplete()
end
