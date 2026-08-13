--古代の機械工兵
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ③：这张卡攻击的伤害步骤结束时，以对方场上1张魔法·陷阱卡为对象发动。那张对方的魔法·陷阱卡破坏。
function c1953925.initial_effect(c)
	-- 『只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化』（①）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c1953925.distg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SELF_DESTROY)
	c:RegisterEffect(e2)
	-- 『这张卡为对象的陷阱卡的效果无效化并破坏』（①，对应连锁处理实现）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c1953925.disop)
	c:RegisterEffect(e3)
	-- 『这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动』（②）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(c1953925.aclimit)
	e4:SetCondition(c1953925.actcon)
	c:RegisterEffect(e4)
	-- 『这张卡攻击的伤害步骤结束时，以对方场上1张魔法·陷阱卡为对象发动。那张对方的魔法·陷阱卡破坏。』（③）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(1953925,0))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetCondition(c1953925.descon)
	e5:SetTarget(c1953925.destg)
	e5:SetOperation(c1953925.desop)
	c:RegisterEffect(e5)
end
-- e1/e2的Target过滤函数：判断某张魔陷是否为陷阱卡，且其效果对象是否包含本卡，以此将『以这张卡为对象的陷阱卡』筛选出来。
function c1953925.distg(e,c)
	if not c:IsType(TYPE_TRAP) or c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsContains(e:GetHandler())
end
-- 连锁处理时的操作函数：若当前发动的效果是陷阱卡效果、具有取对象标志且对象包含本卡，则将那个连锁无效；若无效成功且该陷阱卡仍与效果关联，则将其破坏。
function c1953925.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsType(TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 取出当前连锁效果的对象卡组，用于检查本卡是否被该效果选为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsContains(e:GetHandler()) then
		-- 尝试无效当前连锁，并且只有在该陷阱卡仍与发动效果保持关联时才继续处理破坏。
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 以效果原因破坏该陷阱卡。
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
-- 作为EFFECT_CANNOT_ACTIVATE的Value判断函数：仅禁止『魔法·陷阱卡的发动』（EFFECT_TYPE_ACTIVATE），实现对方不能发动魔法陷阱卡。
function c1953925.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 作为禁止发动效果的发动条件：只有本卡进行攻击时才适用（对应『这张卡攻击的场合』）。
function c1953925.actcon(e)
	-- 判定当前攻击怪兽是否就是本卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- ③的发动条件：本卡是进行攻击的怪兽，并且在伤害步骤结束时仍与战斗相关或处于战斗破坏状态，即满足『这张卡攻击的伤害步骤结束时』。
function c1953925.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击者为本卡且本卡在伤害步骤结束时仍与战斗相关或战斗破坏状态，保证是本次攻击的伤害步骤结束时。
	return e:GetHandler()==Duel.GetAttacker() and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
end
-- 对象选择过滤器：只选择魔法·陷阱卡。
function c1953925.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 取对象处理：若系统询问对象合法性则检查该卡是否为对方场上的魔法·陷阱卡；发动时先返回可发动，然后提示玩家选择，并从对方场上选择1张魔法·陷阱卡作为对象，同时登记操作信息为破坏。
function c1953925.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c1953925.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示『请选择要破坏的卡』的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c1953925.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记本连锁的效果信息：该效果将破坏选择的对象组，用于后续的卡牌效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：获得对象卡，若该卡仍与效果关联，则将其破坏。
function c1953925.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本连锁的对象卡（即选择的对方魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该魔法·陷阱卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
