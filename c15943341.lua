--リローデッド・シリンダー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的卡组·墓地选1张「魔法筒」在自己场上盖放。从卡组盖放的场合，那张卡在盖放的回合也能发动。
-- ②：自己把「魔法筒」发动时，把墓地的这张卡除外才能发动。那个效果给与对方的伤害变成2倍。
function c15943341.initial_effect(c)
	-- ①：从自己的卡组·墓地选1张「魔法筒」在自己场上盖放。从卡组盖放的场合，那张卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetTarget(c15943341.target)
	e1:SetOperation(c15943341.activate)
	c:RegisterEffect(e1)
	-- ②：自己把「魔法筒」发动时，把墓地的这张卡除外才能发动。那个效果给与对方的伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15943341,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,15943341)
	e2:SetRange(LOCATION_GRAVE)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c15943341.ddcon)
	e2:SetOperation(c15943341.ddop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可以盖放的「魔法筒」卡片
function c15943341.setfilter(c)
	return c:IsCode(62279055) and c:IsSSetable()
end
-- 效果发动时的处理函数，检查是否满足盖放条件
function c15943341.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在满足条件的「魔法筒」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c15943341.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 过滤函数，用于判断卡片是否来自卡组
function c15943341.checkfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 处理①效果的发动，选择并盖放「魔法筒」
function c15943341.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择一张「魔法筒」进行盖放
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15943341.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片盖放
		Duel.SSet(tp,g:GetFirst())
		-- 获取实际操作的卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(c15943341.checkfilter,1,nil,tp) then
			-- 适用「上膛圆筒弹巢」的效果来发动
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(15943341,1))  --"适用「上膛圆筒弹巢」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end
-- 判断是否为己方发动的「魔法筒」效果
function c15943341.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(62279055)
end
-- 设置伤害翻倍效果
function c15943341.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 创建并注册伤害翻倍效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetLabel(cid)
	e1:SetValue(c15943341.damval)
	e1:SetReset(RESET_CHAIN)
	-- 将伤害翻倍效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 计算伤害值时的处理函数，判断是否触发翻倍
function c15943341.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前连锁的唯一标识
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return val*2
end
