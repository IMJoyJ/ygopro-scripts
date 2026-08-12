--発禁令
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1个卡名才能发动。这个回合，对方不能把原本卡名和宣言的卡相同的卡的效果发动。这次决斗中，自己不能把原本卡名和宣言的卡相同的卡的效果发动。
function c64964750.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：宣言1个卡名才能发动。这个回合，对方不能把原本卡名和宣言的卡相同的卡的效果发动。这次决斗中，自己不能把原本卡名和宣言的卡相同的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64964750+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c64964750.target)
	e1:SetOperation(c64964750.operation)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理，提示并让玩家宣言一个卡名，并将宣言的卡名作为目标参数保存
function c64964750.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 给发动玩家发送“请宣言一个卡名”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让发动玩家宣言一个卡片卡名
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡名设置为当前连锁的对象参数，以便在效果处理时获取
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为“发动时宣言卡名的效果”
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 卡片发动成功后的效果处理，获取宣言的卡名，并分别为双方玩家注册限制发动效果的全局效果
function c64964750.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时宣言并保存的卡名参数
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	-- 这个回合，对方不能把原本卡名和宣言的卡相同的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	e1:SetLabel(ac)
	e1:SetValue(c64964750.aclimit)
	-- 将限制对方发动效果的全局效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
	-- 这次决斗中，自己不能把原本卡名和宣言的卡相同的卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetLabel(ac)
	e2:SetValue(c64964750.aclimit)
	-- 将限制自己发动效果的全局效果注册给发动玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制发动效果的过滤条件，判断要发动的卡片的原本卡名是否与宣言的卡名相同
function c64964750.aclimit(e,re,tp)
	local ac=e:GetLabel()
	return re:GetHandler():IsOriginalCodeRule(ac)
end
