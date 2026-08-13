--ビビット騎士
-- 效果：
-- 自己场上的兽战士族·光属性怪兽1只成为对方的卡的效果的对象时或者成为对方怪兽的攻击对象时才能发动。成为对象的自己怪兽直到下次的自己的准备阶段时从游戏中除外，这张卡从手卡特殊召唤。
function c52575195.initial_effect(c)
	-- 自己场上的兽战士族·光属性怪兽1只成为对方的卡的效果的对象时才能发动。成为对象的自己怪兽直到下次的自己的准备阶段时从游戏中除外，这张卡从手卡特殊召唤。
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
	-- 自己场上的兽战士族·光属性怪兽1只成为对方怪兽的攻击对象时才能发动。成为对象的自己怪兽直到下次的自己的准备阶段时从游戏中除外，这张卡从手卡特殊召唤。
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
-- 作为第1类触发效果的发动条件：确认发动者是对方，且对方发动的是取对象的效果，对象正好是我方场上的表侧表示·光属性·兽战士族怪兽1只。
function c52575195.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从当前连锁信息中取出对方所发效果选择的取对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
		and tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsRace(RACE_BEASTWARRIOR)
end
-- 作为第2类触发效果的发动条件：确认这是对方回合（自己不是回合玩家），并且我方场上的表侧表示·光属性·兽战士族怪兽被对方怪兽选为攻击对象。
function c52575195.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己就是当前回合玩家，则不可能是被对方怪兽攻击，因此发动条件不成立。
	if tp==Duel.GetTurnPlayer() then return false end
	-- 取得当前被攻击的怪兽（即攻击对象）。
	local tc=Duel.GetAttackTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsRace(RACE_BEASTWARRIOR)
end
-- 效果发动时的合法性检查和目标登记：取出之前记录的作为对象的怪兽，确认其可被除外、自己场上能提供特殊召唤位置、本卡不在连锁处理中且可特殊召唤。
function c52575195.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 在检查阶段确认：对象怪兽可以被除外，且自己场上拥有可用的主要怪兽区空格（至少为0，因对象先除外后会空出格子）。
	if chk==0 then return tc:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>=0
		and not e:GetHandler():IsStatus(STATUS_CHAINING)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将作为对象的自己怪兽登记为当前连锁的处理对象，使其与效果建立关联，并在处理时可通过GetFirstTarget取得。
	Duel.SetTargetCard(tc)
	-- 登记操作信息：本连锁效果预定将对象怪兽1只除外，供系统及其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	-- 登记操作信息：本连锁效果预定将这张卡（手卡中的机灵兔骑士）1只特殊召唤，供系统及其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若对象怪兽仍与效果关联且仍由自己控制，则将其以暂时除外的方式除外；成功后为它注册在下次自己的准备阶段返回场上的效果；然后若这张卡仍与效果关联，则从手卡把它特殊召唤。
function c52575195.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联且仍由自己控制后，以效果·暂时除外的方式将其除外；若除外成功则继续后续处理。
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 成为对象的自己怪兽直到下次的自己的准备阶段时从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCountLimit(1)
		-- 判断当前是否为本卡控制者的回合，以便计算“下次自己的准备阶段”对应的回合数。
		if Duel.GetTurnPlayer()==tp then
			-- 如果当前正处于抽卡阶段，说明下一个准备阶段就在本回合，不需要跨回合计算。
			if Duel.GetCurrentPhase()==PHASE_DRAW then
				-- 将延迟效果触发时机记录为当前回合数（抽卡阶段后紧接着的就是本回合的准备阶段）。
				e1:SetLabel(Duel.GetTurnCount())
			else
				-- 将延迟效果触发时机记录为当前回合数加2（本回合已过准备阶段，需经过对方回合后到自己下回合才到达下一个自己的准备阶段）。
				e1:SetLabel(Duel.GetTurnCount()+2)
			end
		else
			-- 将延迟效果触发时机记录为当前回合数加1（当前是对方回合，下一个自己的准备阶段在自己下一个回合）。
			e1:SetLabel(Duel.GetTurnCount()+1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c52575195.retcon)
		e1:SetOperation(c52575195.retop)
		tc:RegisterEffect(e1)
		if not c:IsRelateToEffect(e) then return end
		-- 从手卡将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 延迟效果的触发条件：当前回合数等于预先记录的回合数，即到了要返回的自己的准备阶段。
function c52575195.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于记录的目标回合数。
	return Duel.GetTurnCount()==e:GetLabel()
end
-- 延迟效果处理：将被暂时除外的对象怪兽返回场上，并重置（结束）该延迟效果。
function c52575195.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果上记录的怪兽（之前被暂时除外的那只）返回场上。
	Duel.ReturnToField(e:GetHandler())
	e:Reset()
end
