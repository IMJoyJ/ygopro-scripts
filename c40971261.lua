--亡龍の旋律
-- 效果：
-- 宣言1个卡名才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，每次宣言的卡的效果发动，把那个效果发动的卡的原本持有者的基本分变成一半。这个效果适用的回合的结束阶段这张卡送去墓地。
-- ②：对方场上有怪兽存在的场合，这张卡不会被效果破坏。
function c40971261.initial_effect(c)
	-- 宣言1个卡名才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40971261.target)
	e1:SetOperation(c40971261.activate)
	c:RegisterEffect(e1)
	-- 每次宣言的卡的效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetLabelObject(e1)
	e2:SetOperation(c40971261.regop)
	c:RegisterEffect(e2)
	-- 把那个效果发动的卡的原本持有者的基本分变成一半
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabelObject(e2)
	e3:SetCondition(c40971261.lpcon)
	e3:SetOperation(c40971261.lpop)
	c:RegisterEffect(e3)
	-- 对方场上有怪兽存在的场合，这张卡不会被效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c40971261.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 效果发动时让玩家宣言一个卡名并记录到效果中
function c40971261.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家显示提示信息：请宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家从卡组中宣言一张卡片
	local ac=Duel.AnnounceCard(tp)
	-- 将玩家宣言的卡号设置为当前连锁的目标参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息，声明本次操作需要宣言卡名（CATEGORY_ANNOUNCE）
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 获取之前宣言的卡号并设置为效果的Label值，同时显示卡片动画
function c40971261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标参数（即玩家宣言的卡号）
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	e:SetLabel(ac)
	e:GetHandler():SetHint(CHINT_CARD,ac)
end
-- 连锁发动时检查发动的卡片是否是之前宣言的卡若是则记录该卡的持有者并设置标记
function c40971261.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst():IsCode(e:GetLabelObject():GetLabel()) then
		e:GetHandler():RegisterFlagEffect(40971261,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
		e:SetLabel(eg:GetFirst():GetOwner())
	end
end
-- 条件判断：需要满足标记已设置且当前连锁的卡是宣言的卡
function c40971261.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(40971261)~=0 and re:GetHandler():IsCode(e:GetLabelObject():GetLabelObject():GetLabel())
end
-- 连锁解决时若满足条件则将宣言卡持有者的LP减半并在回合结束阶段将这张卡送墓
function c40971261.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetLabelObject():GetLabel()
	-- 显示卡号为40971261的卡片动画效果
	Duel.Hint(HINT_CARD,0,40971261)
	-- 将指定玩家的生命值设置为当前生命值的一半（向上取整）
	Duel.SetLP(p,math.ceil(Duel.GetLP(p)/2))
	if c:GetFlagEffect(40971262)==0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(40971262,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果适用的回合的结束阶段这张卡送去墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetCondition(c40971261.tgcon)
		e1:SetOperation(c40971261.tgop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在对方回合结束阶段注册一个触发效果用于送墓
		Duel.RegisterEffect(e1,tp)
	end
end
-- 条件判断：检查标记值是否与当前效果匹配以确保是本次登记的送墓效果
function c40971261.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffectLabel(40971262)==e:GetLabel()
end
-- 执行送墓操作的函数
function c40971261.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以效果原因送入墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- ②对方场上有怪兽存在的场合，这张卡不会被效果破坏。的条件判断函数
function c40971261.indcon(e)
	-- 判断对方怪兽区域是否有怪兽存在
	return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_MZONE)>0
end
