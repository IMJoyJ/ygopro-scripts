--ブリザード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1张表侧表示的魔法卡为对象才能发动。这个回合，那张卡以及原本卡名和那张卡相同的魔法卡在场上发动的效果无效化。这个回合中作为对象的卡被送去对方墓地的场合，不去墓地回到对方手卡。
function c51706604.initial_effect(c)
	-- 对应效果原文：这个卡名的卡在1回合只能发动1张。①：以对方场上1张表侧表示的魔法卡为对象才能发动。这个回合，那张卡以及原本卡名和那张卡相同的魔法卡在场上发动的效果无效化。这个回合中作为对象的卡被送去对方墓地的场合，不去墓地回到对方手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,51706604+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51706604.target)
	e1:SetOperation(c51706604.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选器：筛选表侧表示的魔法卡。
function c51706604.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 发动时取对象处理：确认对象并选择对方场上1张表侧表示魔法卡。
function c51706604.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c51706604.filter(chkc) end
	-- 发动合法性检查：场上不存在符合条件的表侧魔法卡时不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51706604.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示选择对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从对方场上选择1张表侧表示魔法卡，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,c51706604.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理：为对象卡及同名卡注册场上发动效果无效化的效果，并为对象卡注册去墓地时改为回手的效果。
function c51706604.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCodeRule()
		-- 对应效果原文：这个回合，那张卡以及原本卡名和那张卡相同的魔法卡在场上发动的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetLabel(code)
		e1:SetCondition(c51706604.discon)
		e1:SetOperation(c51706604.disop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将无效化监视效果注册给当前玩家，使其在该回合持续有效，对符合条件的场上魔法卡发动进行无效。
		Duel.RegisterEffect(e1,tp)
	end
	if tc:IsRelateToEffect(e) then
		-- 对应效果原文：这个回合中作为对象的卡被送去对方墓地的场合，不去墓地回到对方手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e2:SetValue(LOCATION_HAND)
		e2:SetCondition(c51706604.recon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2,true)
	end
end
-- 无效化条件：当前连锁的卡为原本卡名与记录卡名相同的魔法卡，且其发动位置在场上。
function c51706604.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 获取当前连锁的发动位置，用于判断是否为场上发动。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:GetHandler():IsOriginalCodeRule(code) and re:IsActiveType(TYPE_SPELL) and loc&LOCATION_ONFIELD~=0
end
-- 无效化处理：满足条件时使对应连锁上的魔法卡效果无效。
function c51706604.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将指定连锁的效果无效化。
	Duel.NegateEffect(ev)
end
-- 回手替代效果的触发条件：对象卡的原本持有者为对方，确保只有对方持有的卡被送去对方墓地时改为回对方手卡。
function c51706604.recon(e)
	return e:GetHandler():GetOwner()~=e:GetOwnerPlayer()
end
