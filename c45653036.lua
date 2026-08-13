--暴風雨
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「云魔物」的怪兽发动。把选择怪兽的攻击力下降，以下效果适用。
-- ●下降1000：对方场上1张魔法或者陷阱卡破坏。
-- ●下降2000：对方场上2张卡破坏。
function c45653036.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「云魔物」的怪兽发动。把选择怪兽的攻击力下降，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c45653036.target)
	e1:SetOperation(c45653036.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：判定卡片是否满足对象条件，即表侧表示、卡名带有「云魔物」且攻击力在1000以上。
function c45653036.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18) and c:IsAttackAbove(1000)
end
-- 效果发动时的目标选择处理：在发动阶段选择自己场上1只符合条件的表侧表示「云魔物」怪兽作为对象，并确认对象合法性。
function c45653036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45653036.cfilter(chkc) end
	-- 发动合法性检查：若没有满足条件的对象存在，则不能发动该效果。
	if chk==0 then return Duel.IsExistingTarget(c45653036.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示“请选择表侧表示的卡”，引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的表侧表示「云魔物」怪兽作为效果对象（取对象）。
	Duel.SelectTarget(tp,c45653036.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义过滤函数：判定卡片是否为魔法卡或陷阱卡，用于筛选对方场上的魔法陷阱卡。
function c45653036.filter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：取得对象怪兽，若对象仍表侧表示且与效果关联，则根据其攻击力决定可选的下降档次，并执行对应的攻击力下降与破坏处理。
function c45653036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 获取对方场上的所有魔法陷阱卡，作为下降1000时破坏的候选。
		local g1=Duel.GetMatchingGroup(c45653036.filter1,tp,0,LOCATION_ONFIELD,nil)
		-- 获取对方场上的所有卡片，作为下降2000时破坏的候选。
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		local opt=0
		local b1=atk>=1000 and g1:GetCount()>0
		local b2=atk>=2000 and g2:GetCount()>1
		-- 当两种下降选项均可用时，让玩家选择“攻击力下降1000”或“攻击力下降2000”。
		if b1 and b2 then opt=Duel.SelectOption(tp,aux.Stringid(45653036,0),aux.Stringid(45653036,1))  --"攻击力下降1000/攻击力下降2000"
		-- 当仅下降1000可用时，选择“攻击力下降1000”。
		elseif b1 then opt=Duel.SelectOption(tp,aux.Stringid(45653036,0))  --"攻击力下降1000"
		-- 当仅下降2000可用时，选择“攻击力下降2000”，并将选项序号调整为1以对应后续分支。
		elseif b2 then opt=Duel.SelectOption(tp,aux.Stringid(45653036,1))+1  --"攻击力下降2000"
		else opt=2 end
		if opt==0 then
			-- ●下降1000：对方场上1张魔法或者陷阱卡破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 显示“请选择要破坏的卡”提示，让玩家选择要破坏的魔法陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g1:Select(tp,1,1,nil)
			-- 将选中的卡片以效果破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		elseif opt==1 then
			-- ●下降2000：对方场上2张卡破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 显示“请选择要破坏的卡”提示，让玩家选择要破坏的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g2:Select(tp,2,2,nil)
			-- 将选中的2张卡片以效果破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
