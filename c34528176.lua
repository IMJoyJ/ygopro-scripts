--ドラグニティナイト－アーレウス
-- 效果：
-- 调整＋调整以外的同调怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己的魔法与陷阱区域的表侧表示的怪兽卡数量的对方场上的表侧表示卡为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那些卡的效果直到回合结束时无效。
-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只「龙骑兵团」调整特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册同调召唤手续、复活限制、①效果（起动无效）、①的对方回合即时诱发版本（有装备时）、②效果（装备中自身特召并拉墓地龙骑兵团调整）。
function s.initial_effect(c)
	-- 设定同调召唤手续：调整 + 调整以外的同调怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：以最多有自己的魔法与陷阱区域的表侧表示的怪兽卡数量的对方场上的表侧表示卡为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那些卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon1)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.discon2)
	c:RegisterEffect(e2)
	-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只「龙骑兵团」调整特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果作为起动效果的发动条件：这张卡没有装备卡装备时才能发动（有装备时使用另一个效果）。
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()==0
end
-- ①效果在对方回合也能发动的条件：这张卡有装备卡装备（满足时作为诱发即时效果发动）。
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()>0
end
-- 过滤己方魔陷区中表侧表示的怪兽卡（原本持有怪兽类型的卡），用于计算可选择的对方卡片数量上限。
function s.cfilter(c)
	return (c:GetOriginalType()&TYPE_MONSTER)~=0 and c:IsFaceup()
end
-- ①效果的发动时点：计算可选取对象数量上限（己方魔陷区表侧怪兽数），检查对方存在可被无效的表侧卡且上限大于0；选择对方场上1至上限张可被无效的表侧卡，并登记无效操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方魔法与陷阱区域中表侧表示的原怪兽卡的数量，作为可以选择对方场上表侧表示卡的上限。
	local ct=Duel.GetFieldGroup(tp,LOCATION_SZONE,0):FilterCount(s.cfilter,nil)
	-- 当以特定对象发动时，验证该对象是否为对方场上表侧表示且可被无效化的卡（用于取消选择时检查对象是否合法）。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 发动合法性检查：对方场上有至少1张可被无效化的表侧表示卡，且可选数量上限大于0。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示操作者选择要无效的卡片（显示“请选择要无效的卡”的提示信息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1至ct张满足可被无效化条件的表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置本连锁的操作信息：登记为CATEGORY_DISABLE，记录无效的对象及数量，供后续效果或相关卡发动时参照。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果处理：对每个仍与连锁相关的表侧表示对象，使其效果无效（施加无效怪兽效果、无效效果发动/应用的永续效果，并特殊处理陷阱怪兽），直到回合结束时适用；同时将与其相关的连锁无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中仍与效果相关的对象卡集合（处理时进行对象关系确认）。
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历所有被选择且仍与连锁相关的卡片，逐张进行无效处理。
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与该卡片相关的连锁（同一连锁上的效果）一并无效化，重置时机为回合结束时。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- ②效果的发动条件：这张卡装备中才能发动（存在装备这张卡的怪兽）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- ②效果发动时点：确认自己主要怪兽区有空位，且这张卡自身可以特殊召唤；随后设置将自身特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：自己场上主要怪兽区域是否有空闲区域，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，声明将特殊召唤这张卡（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地的“龙骑兵团”调整怪兽的过滤条件：属于「龙骑兵团」系列、是调整怪兽，且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：先特殊召唤自身；若成功且自己有空的怪兽区，并且墓地存在符合条件的「龙骑兵团」调整怪兽，则询问玩家是否追加特殊召唤；若同意，中断连锁处理，从墓地选择1只「龙骑兵团」调整怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身仍与连锁相关，并尝试将这张卡特殊召唤到场上；若特殊召唤成功（返回非0），继续后续追加处理。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 追加特殊召唤前额外确认自己主要怪兽区仍有空位，用于特殊召唤墓地的调整怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合条件的「龙骑兵团」调整怪兽（不受王家长眠之谷影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 弹出是否特殊召唤的确认询问，让玩家选择是否要追加从墓地特殊召唤调整怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使之后的特殊召唤作为另一次特殊召唤处理（避免错过时点）。
		Duel.BreakEffect()
		-- 提示操作者选择要特殊召唤的卡片（显示“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只符合条件的「龙骑兵团」调整怪兽（已过滤王家长眠之谷的影响）。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的「龙骑兵团」调整怪兽表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
