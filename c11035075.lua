--死地誤算守護
-- 效果：
-- ①：自己或对方的墓地1只1星或1阶的怪兽在自己场上特殊召唤，把这张卡装备。
-- ②：自己·对方的结束阶段发动。装备怪兽的等级·阶级上升1。
-- ③：装备怪兽的等级·阶级的以下效果适用。
-- ●3以上：那只怪兽的攻击力上升那个原本攻击力数值。
-- ●5以上：那只怪兽不受对方发动的效果影响。
-- ④：自己准备阶段，装备怪兽的等级·阶级是7以上的场合发动。场上的卡全部送去墓地。
local s,id,o=GetID()
-- 注册全部5个效果：①发动时从双方墓地选1只1星或1阶怪兽特召并装备此卡；②双方结束阶段装备怪兽等级/阶级上升1；③装备怪兽等级/阶级3以上时攻击力上升原本攻击力，5以上时不受对方效果影响；④自己准备阶段等级/阶级7以上时场上的卡全部送去墓地。
function s.initial_effect(c)
	-- 对应①：自己或对方的墓地1只1星或1阶的怪兽在自己场上特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应②：自己·对方的结束阶段发动。装备怪兽的等级·阶级上升1。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- 对应③●3以上：那只怪兽的攻击力上升那个原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.lvcon(3))
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	-- 对应③●5以上：那只怪兽不受对方发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(s.lvcon(5))
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	-- 对应④：自己准备阶段，装备怪兽的等级·阶级是7以上的场合发动。场上的卡全部送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.tgcon2)
	e5:SetTarget(s.tgtg2)
	e5:SetOperation(s.tgop2)
	c:RegisterEffect(e5)
end
-- 发动①的cost处理：给本卡附加连锁结束前留在场上的誓约效果，并注册连锁被无效时取消本卡去墓地的保护效果，以保证本卡能作为装备卡装备。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 取得当前连锁的ID，用于在后续连锁无效时识别是否是本次发动。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 对应①中的“把这张卡装备”：发动后本卡不因规则送去墓地，留在场上以便装备（cost誓约处理）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 对应①：自己或对方的墓地1只1星或1阶的怪兽在自己场上特殊召唤，把这张卡装备。包括cost保护、筛选、特召与装备处理。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将这个连锁被无效时保护本卡不去墓地的效果注册到场上，由tp玩家管理。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时，若本卡仍与该连锁相关，则调用CancelToGrave(false)取消本卡因发动而送墓。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，用于判断是否为本卡发动的连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤函数：选择墓地中1星或1阶且可以被当前效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return (c:IsLevel(1) or c:IsRank(1)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
-- ①效果发动时的条件判定：cost已成立、主怪兽区有空位、墓地存在符合条件的目标。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 确认tp玩家场上有空余的主要怪兽区用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认双方墓地合计存在至少1只满足spfilter的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 将操作信息设为特殊召唤：从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 装备限制函数：本装备卡只允许装备给触发此限制的怪兽（即e:GetOwner()==c的怪兽）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ①效果处理：特殊召唤墓地符合条件的1星/1阶怪兽，并将此卡装备给它；若没能成功装备，则此卡不去墓地。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 主怪兽区有空位时才执行特殊召唤流程。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示框，提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从双方墓地选择1只满足spfilter条件的怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 特殊召唤所选怪兽；返回非0表示召唤成功，接着进行装备。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 把此装备卡装备到该怪兽身上。
			Duel.Equip(tp,c,tc)
			-- 对应①中的“把这张卡装备”：设置装备限制，使这张装备卡只能装备给当前特殊召唤的怪兽。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			c:RegisterEffect(e1)
		end
	end
	if c:IsOnField() and not c:GetEquipTarget() then
		c:CancelToGrave(false)
	end
end
-- ②效果的target：要求此卡当前装备有怪兽，否则不能发动。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():GetEquipTarget() end
end
-- ②效果处理：为装备怪兽追加一个等级/阶级+1的效果（效果适用中每一回合结束阶段都会上升）。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc:IsFaceup() then
		-- 对应②：自己·对方的结束阶段发动。装备怪兽的等级·阶级上升1（实际给装备怪兽施加等级/阶级+1）。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		if tc:IsLevelAbove(1) then
			e1:SetCode(EFFECT_UPDATE_LEVEL)
		else
			e1:SetCode(EFFECT_UPDATE_RANK)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 生成条件函数：判断装备怪兽的等级或阶级是否≥lv，用于③的攻击力上升和免疫效果的开启条件。
function s.lvcon(lv)
	return function(e)
				local tc=e:GetHandler():GetEquipTarget()
				return tc:IsLevelAbove(lv) or tc:IsRankAbove(lv)
			end
end
-- 取装备怪兽的原本攻击力作为③的攻击力上升数值。
function s.atkval(e,c)
	return c:GetBaseAttack()
end
-- 免疫筛选：对方玩家发动的、非本卡自身的已激活效果，装备怪兽不受其影响。
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActivated()
end
-- ④的发动条件：自己准备阶段且装备怪兽等级/阶级≥7。
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 确认当前回合玩家是自己，即处于自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
		and (tc:IsLevelAbove(7) or tc:IsRankAbove(7))
end
-- ④的target：将场上所有能送去墓地的卡加入对象，并设置操作信息。
function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得场上所有能被效果送去墓地的卡（用于设置操作信息中的对象和数量）。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置本效果将把上述全部卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,dg,dg:GetCount(),0,0)
end
-- ④效果处理：把场上所有能被效果送去墓地的卡全部送去墓地。
function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前场上所有能被效果送去墓地的卡（处理阶段再次获取，保证实际送墓）。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因将取得的所有卡送去墓地。
	Duel.SendtoGrave(dg,REASON_EFFECT)
end
