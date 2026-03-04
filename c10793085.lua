--鉄獣の咆哮
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有连接怪兽存在的场合，从卡组·额外卡组把1张「铁兽」卡送去墓地，以场上1只效果怪兽为对象才能发动。送去墓地的卡种类的以下效果适用。
-- ●怪兽：作为对象的怪兽的攻击力直到回合结束时变成0。
-- ●魔法：作为对象的怪兽的效果直到回合结束时无效。
-- ●陷阱：作为对象的怪兽回到手卡。
function c10793085.initial_effect(c)
	-- ①：自己场上有连接怪兽存在的场合，从卡组·额外卡组把1张「铁兽」卡送去墓地，以场上1只效果怪兽为对象才能发动。
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
-- 用于筛选场上表侧表示的连接怪兽
function c10793085.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果发动的条件判断函数
function c10793085.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的连接怪兽
	return Duel.IsExistingMatchingCard(c10793085.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 用于筛选可以作为cost送去墓地的「铁兽」卡
function c10793085.costfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x14d)
		-- 检查自己场上是否存在满足条件的效果怪兽作为对象
		and Duel.IsExistingTarget(c10793085.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetType())
end
-- 用于筛选可以作为对象的效果怪兽
function c10793085.tgfilter(c,type)
	if type==nil then return false end
	if not (c:IsFaceup() and c:IsType(TYPE_EFFECT)) then return false end
	if type&TYPE_MONSTER~=0 then
		return c:GetAttack()>0
	elseif type&TYPE_SPELL~=0 then
		-- 判断对象怪兽是否可以被魔法效果无效化
		return aux.NegateMonsterFilter(c) and Duel.GetCurrentPhase()~=PHASE_DAMAGE
	elseif type&TYPE_TRAP~=0 then
		-- 判断对象怪兽是否可以回到手卡
		return c:IsAbleToHand() and Duel.GetCurrentPhase()~=PHASE_DAMAGE
	end
	return false
end
-- 效果的处理函数，用于选择对象和设置效果分类
function c10793085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10793085.tgfilter(chkc,e:GetLabel()) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己卡组或额外卡组是否存在至少1张「铁兽」卡可以作为cost
		and Duel.IsExistingMatchingCard(c10793085.costfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组或额外卡组选择1张「铁兽」卡送去墓地
	local g=Duel.SelectMatchingCard(tp,c10793085.costfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,tp)
	-- 将选中的卡送去墓地作为发动cost
	Duel.SendtoGrave(g,REASON_COST)
	local type=g:GetFirst():GetType()
	e:SetLabel(type)
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择场上1只满足条件的效果怪兽作为对象
	local tag=Duel.SelectTarget(tp,c10793085.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,type)
	if type&TYPE_MONSTER~=0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	elseif type&TYPE_SPELL~=0 then
		e:SetCategory(CATEGORY_DISABLE)
		-- 设置效果分类为无效化
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tag,1,0,0)
	elseif type&TYPE_TRAP~=0 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置效果分类为回到手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tag,1,0,0)
	end
end
-- 效果的执行函数，用于处理效果的最终效果
function c10793085.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local type=e:GetLabel()
	if type==nil then return end
	if tc:IsRelateToEffect(e) then
		if type&TYPE_MONSTER~=0 and tc:IsFaceup() then
			-- 使对象怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		if type&TYPE_SPELL~=0 and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			-- 使对象怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使对象怪兽的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使对象怪兽的效果在回合结束时重置
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		if type&TYPE_TRAP~=0 then
			-- 将对象怪兽送回手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
