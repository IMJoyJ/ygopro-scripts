--グレイドル・スプリット
-- 效果：
-- 「灰篮分裂」的②的效果1回合只能使用1次。
-- ①：以自己场上1只怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只怪兽装备。
-- ②：自己主要阶段，把这张卡的效果装备的这张卡送去墓地才能发动。这张卡装备过的怪兽破坏，从卡组把2只「灰篮」怪兽特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段破坏。
function c75361204.initial_effect(c)
	-- ①：以自己场上1只怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前以外的时机（配合伤害步骤发动权限使用）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c75361204.cost)
	e1:SetTarget(c75361204.target)
	e1:SetOperation(c75361204.operation)
	c:RegisterEffect(e1)
end
-- 装备魔法/陷阱卡发动时的标准Cost处理，用于处理卡片留在场上以及连锁被无效时送去墓地的规则。
function c75361204.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作攻击力上升500的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c75361204.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在连锁被无效时将该卡送去墓地。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：取消该卡不送去墓地的状态，使其正常送去墓地。
function c75361204.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 装备卡发动的对象选择与合法性检测。
function c75361204.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息为装备1张卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动时的效果处理：将自身装备给目标怪兽，并赋予攻击力上升效果、装备限制以及送墓特召的②效果。
function c75361204.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取作为装备对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作攻击力上升500的装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作攻击力上升500的装备卡使用给那只怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c75361204.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- ②：自己主要阶段，把这张卡的效果装备的这张卡送去墓地才能发动。这张卡装备过的怪兽破坏，从卡组把2只「灰篮」怪兽特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetCountLimit(1,75361204)
		e3:SetCondition(c75361204.spcon)
		e3:SetCost(c75361204.spcost)
		e3:SetTarget(c75361204.sptg)
		e3:SetOperation(c75361204.spop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给该卡效果选择的怪兽，或者自己场上的怪兽。
function c75361204.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
-- ②效果的发动条件：必须装备有怪兽，且在自己的主要阶段。
function c75361204.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡当前是否有装备对象，且当前回合玩家是自己。
	return e:GetHandler():GetEquipTarget() and Duel.GetTurnPlayer()==tp
		-- 检查当前阶段是否为主要阶段1或主要阶段2。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ②效果的发动Cost：将自身送去墓地，并记录原本装备的怪兽。
function c75361204.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将作为Cost的这张卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「灰篮」怪兽，且卡组中还存在另一只不同名的「灰篮」怪兽。
function c75361204.spfilter1(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在另一只与第一只不同名的「灰篮」怪兽。
		and Duel.IsExistingMatchingCard(c75361204.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤卡组中与指定卡名不同、且可以特殊召唤的「灰篮」怪兽。
function c75361204.spfilter2(c,e,tp,code)
	return c:IsSetCard(0xd1) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检测特殊召唤限制、怪兽区域空位，并设置破坏与特殊召唤的操作信息。
function c75361204.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有可用的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「灰篮」怪兽组合。
		and Duel.IsExistingMatchingCard(c75361204.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	local ec=e:GetLabelObject()
	ec:CreateEffectRelation(e)
	-- 设置连锁操作信息为破坏原本装备的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
	-- 设置连锁操作信息为从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果的效果处理：破坏原本装备的怪兽，并从卡组特殊召唤2只不同名的「灰篮」怪兽，这些怪兽在结束阶段破坏。
function c75361204.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 检查原本装备的怪兽是否仍在场上表侧表示，并将其破坏。
	if ec:IsRelateToEffect(e) and ec:IsFaceup() and Duel.Destroy(ec,REASON_EFFECT)~=0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有2个或以上可用的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local fid=e:GetHandler():GetFieldID()
		-- 提示玩家选择要特殊召唤的第一只怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择第一只满足条件的「灰篮」怪兽。
		local g1=Duel.SelectMatchingCard(tp,c75361204.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc1=g1:GetFirst()
		if not tc1 then return end
		-- 提示玩家选择要特殊召唤的第二只怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择第二只与第一只不同名的「灰篮」怪兽。
		local g2=Duel.SelectMatchingCard(tp,c75361204.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc1:GetCode())
		local tc2=g2:GetFirst()
		-- 准备以表侧表示特殊召唤第一只怪兽。
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 准备以表侧表示特殊召唤第二只怪兽。
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		tc1:RegisterFlagEffect(75361204,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc2:RegisterFlagEffect(75361204,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 完成上述怪兽的特殊召唤。
		Duel.SpecialSummonComplete()
		g1:Merge(g2)
		g1:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g1)
		e1:SetCondition(c75361204.descon)
		e1:SetOperation(c75361204.desop)
		-- 注册全局延迟效果，用于在结束阶段破坏特殊召唤的怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤带有特定标识且需要被破坏的怪兽。
function c75361204.desfilter(c,fid)
	return c:GetFlagEffectLabel(75361204)==fid
end
-- 结束阶段破坏效果的触发条件：检查被特殊召唤的怪兽是否至少有1只仍存在于场上。
function c75361204.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c75361204.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的处理：将依然存在于场上的被特殊召唤的怪兽破坏。
function c75361204.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c75361204.desfilter,nil,e:GetLabel())
	-- 破坏这些被特殊召唤的怪兽。
	Duel.Destroy(tg,REASON_EFFECT)
end
