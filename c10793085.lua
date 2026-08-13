--鉄獣の咆哮
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有连接怪兽存在的场合，从卡组·额外卡组把1张「铁兽」卡送去墓地，以场上1只效果怪兽为对象才能发动。送去墓地的卡种类的以下效果适用。
-- ●怪兽：作为对象的怪兽的攻击力直到回合结束时变成0。
-- ●魔法：作为对象的怪兽的效果直到回合结束时无效。
-- ●陷阱：作为对象的怪兽回到手卡。
function c10793085.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有连接怪兽存在的场合，从卡组·额外卡组把1张「铁兽」卡送去墓地，以场上1只效果怪兽为对象才能发动。送去墓地的卡种类的以下效果适用。●怪兽：作为对象的怪兽的攻击力直到回合结束时变成0。●魔法：作为对象的怪兽的效果直到回合结束时无效。●陷阱：作为对象的怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCountLimit(1,10793085+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10793085.condition)
	e1:SetTarget(c10793085.target)
	e1:SetOperation(c10793085.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且种族/属性为连接怪兽（TYPE_LINK），用于判断自己场上是否存在连接怪兽。
function c10793085.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 发动条件判定：检查自己场上主要怪兽区是否存在至少1张表侧表示的连接怪兽。
function c10793085.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 在自己场上检索是否存在1张以上满足表侧连接怪兽条件的卡，以此作为效果发动的前提条件。
	return Duel.IsExistingMatchingCard(c10793085.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 代价过滤器：从卡组·额外卡组选出可作代价送去墓地且具有「铁兽」字段的卡，同时还要确保场上存在能成为对象的效果怪兽。
function c10793085.costfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x14d)
		-- 确认存在合法的对象：根据要送去墓地的卡的种类，场上必须有满足对应处理条件（攻击力可归0/效果可被无效/可回手）的表侧效果怪兽。
		and Duel.IsExistingTarget(c10793085.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetType())
end
-- 对象过滤器：对象必须是表侧表示的效果怪兽，再按送去墓地的卡是怪兽/魔法/陷阱分别判定其攻击力可变为0、效果可被无效或可回手。
function c10793085.tgfilter(c,type)
	if type==nil then return false end
	if not (c:IsFaceup() and c:IsType(TYPE_EFFECT)) then return false end
	if type&TYPE_MONSTER~=0 then
		return c:GetAttack()>0
	elseif type&TYPE_SPELL~=0 then
		-- 魔法种类时的额外条件：对象必须是表侧表示且效果未被无效的效果怪兽，并且当前不是伤害阶段。
		return aux.NegateMonsterFilter(c) and Duel.GetCurrentPhase()~=PHASE_DAMAGE
	elseif type&TYPE_TRAP~=0 then
		-- 陷阱种类时的额外条件：对象怪兽必须能够回到手卡，并且当前不是伤害阶段。
		return c:IsAbleToHand() and Duel.GetCurrentPhase()~=PHASE_DAMAGE
	end
	return false
end
-- 发动时处理：合法性检查时确认存在可送墓的「铁兽」卡且可选的合法对象；选择对象时验证对象位于怪兽区且符合所送墓卡种类对应的过滤条件。
function c10793085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10793085.tgfilter(chkc,e:GetLabel()) end
	if chk==0 then return e:IsCostChecked()
		-- 检查从卡组·额外卡组是否存在至少1张既能作为代价送去墓地又能使场上存在合法对象的「铁兽」卡。
		and Duel.IsExistingMatchingCard(c10793085.costfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,tp) end
	-- 向玩家显示选择提示：请选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家从自己的卡组·额外卡组选择1张满足条件的「铁兽」卡。
	local g=Duel.SelectMatchingCard(tp,c10793085.costfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,tp)
	-- 将选择的「铁兽」卡作为发动代价送入墓地（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
	local type=g:GetFirst():GetType()
	e:SetLabel(type)
	-- 向玩家显示选择提示：请选择效果的对象（HINTMSG_TARGET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的表侧效果怪兽作为效果对象，并将其登记为本连锁的对象。
	local tag=Duel.SelectTarget(tp,c10793085.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,type)
	if type&TYPE_MONSTER~=0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	elseif type&TYPE_SPELL~=0 then
		e:SetCategory(CATEGORY_DISABLE)
		-- 若送去墓地的卡是魔法卡，登记操作信息：将对对象怪兽发动无效效果（CATEGORY_DISABLE）。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tag,1,0,0)
	elseif type&TYPE_TRAP~=0 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 若送去墓地的卡是陷阱卡，登记操作信息：将使对象怪兽回到手卡（CATEGORY_TOHAND）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tag,1,0,0)
	end
end
-- 效果处理：根据发动时送去墓地的卡种类对对象怪兽适用对应效果——怪兽→攻击力变成0；魔法→效果无效；陷阱→回到手卡。
function c10793085.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本连锁登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local type=e:GetLabel()
	if type==nil then return end
	if tc:IsRelateToEffect(e) then
		if type&TYPE_MONSTER~=0 and tc:IsFaceup() then
			-- ●怪兽：作为对象的怪兽的攻击力直到回合结束时变成0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		if type&TYPE_SPELL~=0 and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			-- 使对象怪兽相关的连锁被无效化，并持续到回合结束；这是魔法卡种类“效果无效”处理的一部分，防止其已发动的效果继续处理。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- ●魔法：作为对象的怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- ●魔法：作为对象的怪兽的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		if type&TYPE_TRAP~=0 then
			-- 把对象怪兽从场上送回持有者手卡（对应陷阱卡种类）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
