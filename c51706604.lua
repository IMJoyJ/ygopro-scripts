--ブリザード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1张表侧表示的魔法卡为对象才能发动。这个回合，那张卡以及原本卡名和那张卡相同的魔法卡在场上发动的效果无效化。这个回合中作为对象的卡被送去对方墓地的场合，不去墓地回到对方手卡。
function c51706604.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,51706604+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51706604.target)
	e1:SetOperation(c51706604.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的魔法卡（表侧表示）
function c51706604.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果作用：选择对方场上一张表侧表示的魔法卡作为对象
function c51706604.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c51706604.filter(chkc) end
	-- 判断是否满足发动条件：对方场上存在一张表侧表示的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c51706604.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对象：从对方场上选择一张表侧表示的魔法卡
	Duel.SelectTarget(tp,c51706604.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果作用：使对象魔法卡及其同名魔法卡在场上的发动效果无效化，并设定返回手牌的效果
function c51706604.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCodeRule()
		-- 效果原文内容：①：以对方场上1张表侧表示的魔法卡为对象才能发动。这个回合，那张卡以及原本卡名和那张卡相同的魔法卡在场上发动的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetLabel(code)
		e1:SetCondition(c51706604.discon)
		e1:SetOperation(c51706604.disop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到全局环境，使该效果在指定阶段结束时重置
		Duel.RegisterEffect(e1,tp)
	end
	if tc:IsRelateToEffect(e) then
		-- 效果原文内容：这个回合中作为对象的卡被送去对方墓地的场合，不去墓地回到对方手卡。
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
-- 判断连锁效果是否为同名魔法卡且在场上发动
function c51706604.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 获取当前连锁效果发生的地点
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:GetHandler():IsOriginalCodeRule(code) and re:IsActiveType(TYPE_SPELL) and loc&LOCATION_ONFIELD~=0
end
-- 效果作用：使符合条件的连锁效果无效
function c51706604.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效化
	Duel.NegateEffect(ev)
end
-- 判断对象卡是否被送入墓地
function c51706604.recon(e)
	return e:GetHandler():GetOwner()~=e:GetOwnerPlayer()
end
