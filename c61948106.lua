--ガトムズの非常召集
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
-- ①：自己场上有「X-剑士」同调怪兽存在的场合，以自己墓地2只「X-剑士」怪兽为对象才能发动。那2只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽攻击力变成0，这个回合的结束阶段破坏。
function c61948106.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。①：自己场上有「X-剑士」同调怪兽存在的场合，以自己墓地2只「X-剑士」怪兽为对象才能发动。那2只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽攻击力变成0，这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,61948106+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c61948106.spcon)
	e1:SetCost(c61948106.spcost)
	e1:SetTarget(c61948106.sptg)
	e1:SetOperation(c61948106.spop)
	c:RegisterEffect(e1)
end
-- 发动代价处理函数，限制不能在主要阶段2以外的阶段发动，并注册发动的回合自己不能进行战斗阶段的效果。
function c61948106.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否不是主要阶段2（因为发动的回合不能进行战斗阶段，如果在主要阶段2则无法满足此限制）。
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：自己场上有「X-剑士」同调怪兽存在的场合，以自己墓地2只「X-剑士」怪兽为对象才能发动。那2只怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能进行战斗阶段”的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：场上表侧表示的「X-剑士」同调怪兽。
function c61948106.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d) and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件：自己场上存在「X-剑士」同调怪兽。
function c61948106.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽。
	return Duel.IsExistingMatchingCard(c61948106.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中可以特殊召唤的「X-剑士」怪兽。
function c61948106.spfilter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动准备处理函数，进行对象选择和特殊召唤的操作信息设置。
function c61948106.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61948106.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于1。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在2只可以作为对象的「X-剑士」怪兽。
		and Duel.IsExistingTarget(c61948106.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只「X-剑士」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c61948106.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置连锁操作信息，表明此效果包含特殊召唤这2只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理函数，将选中的2只怪兽无视召唤条件特殊召唤，使其攻击力变成0，并注册结束阶段破坏的效果。
function c61948106.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取当前连锁中作为对象且仍与此效果有关联的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=2 then return end
	-- 检查自己场上的怪兽区域空位数是否不足2个，若不足则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 尝试将目标怪兽无视召唤条件以表侧表示特殊召唤（分步处理）。
		if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(61948106,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c61948106.descon)
	e1:SetOperation(c61948106.desop)
	-- 注册在结束阶段触发的全局时点效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：带有当前特殊召唤标记的怪兽。
function c61948106.desfilter(c,fid)
	return c:GetFlagEffectLabel(61948106)==fid
end
-- 破坏效果的触发条件：检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该效果并释放卡片组内存。
function c61948106.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c61948106.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 破坏效果的处理：破坏所有带有对应标记的怪兽。
function c61948106.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c61948106.desfilter,nil,e:GetLabel())
	-- 因效果将目标怪兽破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
