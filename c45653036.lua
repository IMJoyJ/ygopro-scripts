--暴風雨
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「云魔物」的怪兽发动。把选择怪兽的攻击力下降，以下效果适用。
-- ●下降1000：对方场上1张魔法或者陷阱卡破坏。
-- ●下降2000：对方场上2张卡破坏。
function c45653036.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点、自由连锁、取对象效果，并注册目标选择和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c45653036.target)
	e1:SetOperation(c45653036.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示、云魔物族、攻击力不低于1000的怪兽
function c45653036.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18) and c:IsAttackAbove(1000)
end
-- 目标选择函数：选择自己场上满足条件的1只怪兽
function c45653036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45653036.cfilter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c45653036.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标：选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c45653036.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c45653036.filter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动函数：根据选择的怪兽攻击力决定破坏数量并执行效果
function c45653036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 获取对方场上的魔法或陷阱卡组
		local g1=Duel.GetMatchingGroup(c45653036.filter1,tp,0,LOCATION_ONFIELD,nil)
		-- 获取对方场上的所有卡组
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		local opt=0
		local b1=atk>=1000 and g1:GetCount()>0
		local b2=atk>=2000 and g2:GetCount()>1
		-- 若攻击力下降1000和2000的条件都满足，则让玩家选择效果
		if b1 and b2 then opt=Duel.SelectOption(tp,aux.Stringid(45653036,0),aux.Stringid(45653036,1))  --"攻击力下降1000/攻击力下降2000"
		-- 若仅满足攻击力下降1000的条件，则让玩家选择该效果
		elseif b1 then opt=Duel.SelectOption(tp,aux.Stringid(45653036,0))  --"攻击力下降1000"
		-- 若仅满足攻击力下降2000的条件，则让玩家选择该效果
		elseif b2 then opt=Duel.SelectOption(tp,aux.Stringid(45653036,1))+1  --"攻击力下降2000"
		else opt=2 end
		if opt==0 then
			-- 效果原文：攻击力下降1000
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 提示选择：提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g1:Select(tp,1,1,nil)
			-- 破坏指定数量的卡
			Duel.Destroy(dg,REASON_EFFECT)
		elseif opt==1 then
			-- 效果原文：攻击力下降2000
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 提示选择：提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g2:Select(tp,2,2,nil)
			-- 破坏指定数量的卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
