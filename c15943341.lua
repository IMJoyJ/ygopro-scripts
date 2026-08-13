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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己把「魔法筒」发动时，把墓地的这张卡除外才能发动。那个效果给与对方的伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15943341,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,15943341)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动代价：把墓地中的这张卡除外（COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c15943341.ddcon)
	e2:SetOperation(c15943341.ddop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：对象必须是「魔法筒」（卡号62279055），且可以被盖放到魔法与陷阱区域。
function c15943341.setfilter(c)
	return c:IsCode(62279055) and c:IsSSetable()
end
-- 效果①的发动条件判定：在发动前检查己方卡组或墓地是否存在至少1张满足筛选条件的「魔法筒」。
function c15943341.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0 表示发动合法性检查阶段：若己方卡组·墓地存在符合筛选条件的「魔法筒」则返回 true，使效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15943341.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 判定某张卡是否刚刚从卡组被盖放：检查其之前所在位置是否为卡组（LOCATION_DECK）。
function c15943341.checkfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果①处理：从己方卡组·墓地选择1张「魔法筒」（不受王家长眠之谷影响）盖放到自己魔法陷阱区；若该卡来自卡组，则给它赋予“盖放回合即可发动”的效果。
function c15943341.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示窗口，提示玩家选择要盖放的卡片（HINTMSG_SET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从己方卡组·墓地挑选1张满足setfilter且不受王家长眠之谷影响的「魔法筒」，作为盖放对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15943341.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选出的「魔法筒」里侧表示盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
		-- 获取刚才盖放操作实际处理过的卡片组，用来确认盖放的卡是否来自卡组。
		local og=Duel.GetOperatedGroup()
		if og:IsExists(c15943341.checkfilter,1,nil,tp) then
			-- 从卡组盖放的场合，那张卡在盖放的回合也能发动。
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
-- ②效果的发动条件：当前连锁的发动者是己方，且所发动的效果为「魔法筒」的卡的效果发动（即自己把「魔法筒」发动时）。
function c15943341.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(62279055)
end
-- ②效果处理：把伤害变更效果注册到当前连锁上，使该连锁中「魔法筒」造成的效果伤害变成2倍。
function c15943341.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被连锁的「魔法筒」效果所属连锁的连锁ID并保存，用于识别哪个伤害需要翻倍。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果给与对方的伤害变成2倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetLabel(cid)
	e1:SetValue(c15943341.damval)
	e1:SetReset(RESET_CHAIN)
	-- 将伤害变更效果作为场地效果注册到场上，使其作用于当前连锁（连锁结束后自动重置）。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害变更计算函数：仅当当前处理的效果仍是所对应的「魔法筒」效果（连锁ID一致）并且伤害属于效果伤害时，将伤害翻倍；否则返回原伤害。
function c15943341.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号；若为0说明不在连锁处理中，不进行伤害翻倍。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前正在处理的效果的连锁ID，与之前保存的「魔法筒」连锁ID进行比较，以判断当前效果是否为需要翻倍的那个效果。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return val*2
end
