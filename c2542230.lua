--スカーレッド・コクーン
-- 效果：
-- ①：以自己场上1只龙族同调怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的场合，直到那次伤害步骤结束时对方场上的全部表侧表示怪兽的效果无效化。
-- ③：这张卡被送去墓地的回合的结束阶段，以自己墓地1只「红莲魔龙」为对象才能发动。那只怪兽特殊召唤。
function c2542230.initial_effect(c)
	-- 记录此卡与「红莲魔龙」的关联
	aux.AddCodeList(c,70902743)
	-- ①：以自己场上1只龙族同调怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c2542230.cost)
	e1:SetTarget(c2542230.target)
	e1:SetOperation(c2542230.activate)
	c:RegisterEffect(e1)
	-- ③：这张卡被送去墓地的回合的结束阶段，以自己墓地1只「红莲魔龙」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c2542230.regop)
	c:RegisterEffect(e2)
	-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的场合，直到那次伤害步骤结束时对方场上的全部表侧表示怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2542230,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(c2542230.spcon)
	e3:SetTarget(c2542230.sptg)
	e3:SetOperation(c2542230.spop)
	c:RegisterEffect(e3)
end
-- 设置此卡发动时的费用，使此卡在发动后留在场上并注册连锁被无效时的处理效果
function c2542230.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后留在场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁被无效时的处理效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c2542230.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给对应玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，若为当前连锁则取消送入墓地
function c2542230.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选场上表侧表示的龙族同调怪兽
function c2542230.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 判断是否满足装备目标条件
function c2542230.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2542230.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断场上是否存在满足条件的装备目标
		and Duel.IsExistingTarget(c2542230.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,c2542230.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，包括装备限制和无效化效果
function c2542230.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取装备目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备限制效果，使只有特定怪兽能装备此卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c2542230.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置无效化效果，使对方场上怪兽效果在战斗时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCondition(c2542230.discon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 立即刷新场上状态
		Duel.AdjustInstantly(c)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制函数，判断是否能装备此卡
function c2542230.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 无效化条件函数，判断是否处于战斗状态
function c2542230.discon(e)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断是否为战斗中的攻击怪兽或被攻击怪兽
	return Duel.GetAttacker()==ec or Duel.GetAttackTarget()==ec
end
-- 注册标记，用于记录此卡被送入墓地
function c2542230.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(2542230,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否满足特殊召唤条件，即此卡被送入墓地且为结束阶段
function c2542230.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件
	return c:GetFlagEffect(2542230)~=0 and Duel.GetCurrentPhase()==PHASE_END
end
-- 筛选墓地中的「红莲魔龙」
function c2542230.spfilter(c,e,tp)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤目标条件
function c2542230.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c2542230.spfilter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的特殊召唤目标
		and Duel.IsExistingTarget(c2542230.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择特殊召唤目标
	local g=Duel.SelectTarget(tp,c2542230.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c2542230.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
