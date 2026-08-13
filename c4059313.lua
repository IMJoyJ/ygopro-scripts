--ゴッド・ブレイズ・キャノン
-- 效果：
-- ①：选自己场上1只「太阳神之翼神龙」。那只怪兽直到回合结束时得到以下效果。这张卡的发动和效果不会被无效化。
-- ●这张卡不受对方的效果影响。
-- ●这张卡进行战斗的攻击宣言时，把这个回合没有攻击宣言的自己场上的其他怪兽任意数量解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
-- ●这张卡攻击的伤害计算后才能发动。对方场上的怪兽全部送去墓地。
function c4059313.initial_effect(c)
	-- 记录本卡卡名上记载的「太阳神之翼神龙」的卡号，用于相关联动判定。
	aux.AddCodeList(c,10000010)
	-- ①：选自己场上1只「太阳神之翼神龙」。那只怪兽直到回合结束时得到以下效果。这张卡的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c4059313.target)
	e1:SetOperation(c4059313.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的怪兽：表侧表示、卡名为「太阳神之翼神龙」、且尚未被本卡效果适用过（flag为0）。
function c4059313.filter(c)
	return c:IsFaceup() and c:IsCode(10000010) and c:GetFlagEffect(4059313)==0
end
-- 发动时点检查：自己场上是否存在至少1只符合条件的「太阳神之翼神龙」可供选择。
function c4059313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认自己场上存在至少1只符合过滤条件的「太阳神之翼神龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c4059313.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 发动处理时，从自己场上选择1只符合条件的「太阳神之翼神龙」，使其直到回合结束获得以下效果：不受对方效果影响、攻击宣言时解放其他未攻击怪兽提升攻击力、伤害计算后把对方场上的怪兽全部送去墓地，并使其变更为效果怪兽，同时用标志提示本卡效果适用中。
function c4059313.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要操作的卡”的卡片选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从自己场上选择1只符合条件的「太阳神之翼神龙」。
	local g=Duel.SelectMatchingCard(tp,c4059313.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 手动显示被选择卡的选中动画，并将其记录为当前效果的对象。
		Duel.HintSelection(g)
		-- ●这张卡不受对方的效果影响。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c4059313.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ●这张卡进行战斗的攻击宣言时，把这个回合没有攻击宣言的自己场上的其他怪兽任意数量解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
		local e2=Effect.CreateEffect(tc)
		e2:SetCategory(CATEGORY_ATKCHANGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCondition(c4059313.atkcon)
		e2:SetCost(c4059313.atkcost)
		e2:SetTarget(c4059313.atktg)
		e2:SetOperation(c4059313.atkop)
		tc:RegisterEffect(e2)
		-- ●这张卡攻击的伤害计算后才能发动。对方场上的怪兽全部送去墓地。
		local e3=Effect.CreateEffect(tc)
		e3:SetCategory(CATEGORY_TOGRAVE)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_BATTLED)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetCondition(c4059313.tgcon)
		e3:SetTarget(c4059313.tgtg)
		e3:SetOperation(c4059313.tgop)
		tc:RegisterEffect(e3)
		if not tc:IsType(TYPE_EFFECT) then
			-- 那只怪兽直到回合结束时得到以下效果。
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_ADD_TYPE)
			e4:SetValue(TYPE_EFFECT)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
		end
		tc:RegisterFlagEffect(4059313,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(4059313,0))  --"「神威烈焰加农炮」效果适用中"
	end
end
-- 免疫效果判定：效果来源卡的持有者玩家与本卡控制者不同时，视为对方效果，予以免疫。
function c4059313.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 攻击宣言效果的发动条件：本卡成为攻击宣言的怪兽（攻击者或被攻击目标）时成立。
function c4059313.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回本卡是否为当前攻击宣言中的攻击者或攻击对象。
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 筛选可解放的怪兽：本回合未进行过攻击宣言、原本攻击力大于0，且是自己场上可解放的怪兽（含符合代替解放条件的怪兽）。
function c4059313.atkfilter(c,tp)
	return c:GetAttackAnnouncedCount()==0 and c:GetTextAttack()>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 解放代价：从候选怪兽中选择任意数量解放，并将其原本攻击力合计保存到效果标签，供后续上升攻击力使用。
function c4059313.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 取得自己场上可解放的怪兽，并过滤出满足条件的解放候选组。
	local g=Duel.GetReleaseGroup(tp):Filter(c4059313.atkfilter,e:GetHandler(),tp)
	if chk==0 then return g:GetCount()>0 end
	-- 弹出“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:Select(tp,1,g:GetCount(),nil)
	-- 若存在代替解放效果（如暗影敌托邦），消耗相应效果的使用次数。
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选择的怪兽作为代价解放。
	Duel.Release(rg,REASON_COST)
	local atk=rg:GetSum(Card.GetTextAttack)
	e:SetLabel(100,atk)
end
-- 攻击力上升效果的目标检查：确认已支付解放代价（label=100）后，将上升值写入连锁参数，供效果处理时使用。
function c4059313.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label,atk=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		if label~=100 then return false end
		return true
	end
	e:SetLabel(0,0)
	-- 将计算出的攻击力上升数值记录为当前连锁的目标参数。
	Duel.SetTargetParam(atk)
end
-- 效果处理：若本卡仍在场上且与效果关联，则根据连锁参数赋予本卡攻击力上升效果，直到回合结束。
function c4059313.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 从当前连锁信息中取出之前记录的攻击力上升数值。
		local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 伤害计算后效果的发动条件：仅当本卡作为攻击者进行攻击的伤害计算后可以发动。
function c4059313.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本次战斗中攻击者是否为本卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 伤害计算后效果的发动检查与目标设置：确认对方场上有能送去墓地的怪兽，并登记将对方场上怪兽全部送去墓地的操作信息。
function c4059313.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有能够送去墓地的怪兽作为目标组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 登记效果处理信息：把对方场上全部可送墓怪兽送去墓地（分类为送去墓地）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：将对方场上的全部怪兽送去墓地。
function c4059313.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上能够送去墓地的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因将对方场上全部符合条件的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
