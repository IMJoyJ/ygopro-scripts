--死の罪宝－ルシエラ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只7星以上的魔法师族怪兽为对象才能发动。以下效果各适用。
-- ●作为对象的表侧表示怪兽在这个回合不受其他怪兽的效果影响，下个回合的准备阶段送去墓地。
-- ●对方场上的全部怪兽的攻击力下降作为对象的怪兽的攻击力数值。这个效果让攻击力变成0的场合，再把那怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册主效果
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	-- 限制效果只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽（表侧表示、7星以上、魔法师族）
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
-- 处理效果的发动选择目标，选择自己场上符合条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤函数，用于筛选攻击力不为0的表侧表示怪兽
function s.dfilter(c)
	-- 返回表侧表示且攻击力大于0的怪兽
	return c:IsFaceup() and aux.nzatk(c)
end
-- 效果发动处理函数，执行效果的两个部分
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local chk
	if tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 使目标怪兽在本回合免疫其他怪兽的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.efilter)
		tc:RegisterEffect(e1)
		-- 设置目标怪兽在下个回合准备阶段送去墓地的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		-- 记录当前回合数用于判断时机
		e2:SetLabel(Duel.GetTurnCount())
		e2:SetCondition(s.tgcon)
		e2:SetOperation(s.tgop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		tc:RegisterEffect(e2)
		chk=true
	end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,nil)
	if tc:IsFaceup() and #g>0 then
		-- 中断当前效果处理，使后续处理视为不同时处理
		if chk then Duel.BreakEffect() end
		local atkd=tc:GetAttack()
		local dg=Group.CreateGroup()
		-- 遍历所有对方怪兽并修改其攻击力
		for sc in aux.Next(g) do
			local patk=sc:GetAttack()
			-- 修改目标怪兽攻击力
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atkd)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			if patk~=0 and sc:IsAttack(0) then dg:AddCard(sc) end
		end
		if #dg>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将攻击力变为0的怪兽破坏
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 效果过滤函数，用于判断是否免疫某个效果
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetHandler()
end
-- 判断是否为下个回合准备阶段的条件函数
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否与记录的回合数不同
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 准备阶段处理函数，将目标怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	-- 判断当前回合数是否为记录回合数+1
	if Duel.GetTurnCount()~=e:GetLabel()+1 then return end
	-- 提示对方该卡发动
	Duel.Hint(HINT_CARD,0,id)
	-- 将目标怪兽送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
