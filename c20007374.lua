--集いし願い
-- 效果：
-- ①：自己墓地有龙族同调怪兽5种类以上存在的场合才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽在结束阶段除外。
-- ②：装备怪兽的攻击力上升自己墓地的龙族同调怪兽的攻击力的合计数值。
-- ③：每次装备怪兽战斗破坏对方怪兽，把自己墓地1只龙族同调怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。
function c20007374.initial_effect(c)
	-- 记录此卡为「星尘龙」的同名卡
	aux.AddCodeList(c,44508094)
	-- ①：自己墓地有龙族同调怪兽5种类以上存在的场合才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20007374.condition)
	e1:SetCost(c20007374.cost)
	e1:SetTarget(c20007374.target)
	e1:SetOperation(c20007374.activate)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的攻击力上升自己墓地的龙族同调怪兽的攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c20007374.atkval)
	c:RegisterEffect(e2)
	-- ③：每次装备怪兽战斗破坏对方怪兽，把自己墓地1只龙族同调怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20007374,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c20007374.cacon)
	e4:SetCost(c20007374.cacost)
	e4:SetTarget(c20007374.catg)
	e4:SetOperation(c20007374.caop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选龙族同调怪兽
function c20007374.cfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 判断自己墓地是否拥有5种类以上的龙族同调怪兽
function c20007374.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地所有龙族同调怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c20007374.cfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=5
end
-- 设置发动此卡时的费用，使此卡在发动后不离场并注册连锁被无效时的处理效果
function c20007374.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后不离场
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
	e2:SetOperation(c20007374.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，如果该连锁ID与当前效果ID一致，则取消此卡进入墓地
function c20007374.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤函数，用于筛选可以特殊召唤的星尘龙
function c20007374.filter(c,e,tp)
	return c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查是否有足够的额外卡组特殊召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置发动此卡时的满足条件，包括费用已支付、必须有同调素材、额外卡组有符合条件的星尘龙
function c20007374.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查是否满足同调召唤的素材要求
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在符合条件的星尘龙
		and Duel.IsExistingMatchingCard(c20007374.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置此卡发动时的操作信息，包括特殊召唤的卡、数量、玩家和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动此卡的效果，包括特殊召唤星尘龙、装备、设置除外效果等
function c20007374.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足同调召唤的素材要求
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的星尘龙
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的星尘龙
	local g=Duel.SelectMatchingCard(tp,c20007374.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将星尘龙特殊召唤
		Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将此卡装备给特殊召唤的星尘龙
			Duel.Equip(tp,c,tc)
			-- 设置装备怪兽不能被其他装备卡装备的限制
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c20007374.eqlimit)
			c:RegisterEffect(e1)
		end
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(20007374,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 注册结束阶段除外效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c20007374.rmcon)
		e2:SetOperation(c20007374.rmop)
		-- 将效果e2注册给玩家tp
		Duel.RegisterEffect(e2,tp)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制函数，确保只能装备给此卡
function c20007374.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 结束阶段除外的条件函数，检查是否为当前特殊召唤的星尘龙
function c20007374.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(20007374)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外的操作函数，将星尘龙除外
function c20007374.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将星尘龙除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 过滤函数，用于筛选墓地中的龙族同调怪兽并具有攻击力
function c20007374.atkfilter(c)
	return c20007374.cfilter(c) and c:GetAttack()>0
end
-- 计算墓地中的龙族同调怪兽攻击力总和
function c20007374.atkval(e,c)
	-- 获取自己墓地所有龙族同调怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c20007374.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetSum(Card.GetAttack)
end
-- 判断战斗破坏的怪兽是否为装备怪兽
function c20007374.cacon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- 过滤函数，用于筛选可以作为除外代价的龙族同调怪兽
function c20007374.cafilter(c)
	return c20007374.cfilter(c) and c:IsAbleToRemoveAsCost()
end
-- 设置发动效果时的费用，将1只龙族同调怪兽除外
function c20007374.cacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的龙族同调怪兽可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c20007374.cafilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的龙族同调怪兽
	local g=Duel.SelectMatchingCard(tp,c20007374.cafilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的龙族同调怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置发动效果时的目标，检查装备怪兽是否可以继续攻击
function c20007374.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec:IsChainAttackable(0,true) end
end
-- 发动效果，使装备怪兽可以继续攻击
function c20007374.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	-- 使装备怪兽可以继续攻击
	Duel.ChainAttack()
	-- 设置装备怪兽不能直接攻击的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	ec:RegisterEffect(e1)
end
