--ビビット騎士
-- 效果：
-- 自己场上的兽战士族·光属性怪兽1只成为对方的卡的效果的对象时或者成为对方怪兽的攻击对象时才能发动。成为对象的自己怪兽直到下次的自己的准备阶段时从游戏中除外，这张卡从手卡特殊召唤。
function c52575195.initial_effect(c)
	-- 效果原文内容：自己场上的兽战士族·光属性怪兽1只成为对方的卡的效果的对象时或者成为对方怪兽的攻击对象时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52575195,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52575195.tgcon1)
	e1:SetTarget(c52575195.tgtg)
	e1:SetOperation(c52575195.tgop)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52575195,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c52575195.tgcon2)
	e2:SetTarget(c52575195.tgtg)
	e2:SetOperation(c52575195.tgop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断连锁是否由对方发动且为取对象效果，同时确认目标卡片是否为己方场上1只光属性兽战士族怪兽。
function c52575195.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 规则层面作用：获取当前连锁的目标卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
		and tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsRace(RACE_BEASTWARRIOR)
end
-- 规则层面作用：判断是否为对方怪兽攻击己方怪兽的情况，并确认该怪兽为光属性兽战士族。
function c52575195.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：排除自己回合发动的条件，防止自己攻击自己时触发效果。
	if tp==Duel.GetTurnPlayer() then return false end
	-- 规则层面作用：获取当前被攻击的目标怪兽。
	local tc=Duel.GetAttackTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsRace(RACE_BEASTWARRIOR)
end
-- 规则层面作用：检查是否满足发动条件，包括目标怪兽可除外、己方场上存在召唤空间以及此卡未在连锁中。
function c52575195.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 规则层面作用：判断目标怪兽是否可以除外且己方有足够召唤空间。
	if chk==0 then return tc:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>=0
		and not e:GetHandler():IsStatus(STATUS_CHAINING)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置当前效果的目标卡片为tc。
	Duel.SetTargetCard(tc)
	-- 规则层面作用：设置操作信息，表示将目标怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	-- 规则层面作用：设置操作信息，表示将此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：处理效果发动后执行的操作，包括将目标怪兽除外并注册返回场上的效果，然后特殊召唤自身。
function c52575195.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取当前效果的目标卡片。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否仍然存在于场上且为己方控制，并成功将其除外。
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 效果原文内容：成为对象的自己怪兽直到下次的自己的准备阶段时从游戏中除外，这张卡从手卡特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCountLimit(1)
		-- 规则层面作用：判断当前回合玩家是否为自己。
		if Duel.GetTurnPlayer()==tp then
			-- 规则层面作用：判断当前阶段是否为抽卡阶段。
			if Duel.GetCurrentPhase()==PHASE_DRAW then
				-- 规则层面作用：设置效果标签为当前回合数。
				e1:SetLabel(Duel.GetTurnCount())
			else
				-- 规则层面作用：设置效果标签为当前回合数加二。
				e1:SetLabel(Duel.GetTurnCount()+2)
			end
		else
			-- 规则层面作用：设置效果标签为当前回合数加一。
			e1:SetLabel(Duel.GetTurnCount()+1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c52575195.retcon)
		e1:SetOperation(c52575195.retop)
		tc:RegisterEffect(e1)
		if not c:IsRelateToEffect(e) then return end
		-- 规则层面作用：将此卡特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面作用：判断是否到达设定的回合数以触发返回场上的效果。
function c52575195.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：比较当前回合数与标签中的回合数是否一致。
	return Duel.GetTurnCount()==e:GetLabel()
end
-- 规则层面作用：将目标怪兽返回到场上。
function c52575195.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：将目标怪兽以原表示形式返回到场上。
	Duel.ReturnToField(e:GetHandler())
	e:Reset()
end
