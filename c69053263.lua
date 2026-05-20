--黒薔薇の華園
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把1只「蔷薇龙」怪兽加入手卡。
-- ②：场上的表侧表示怪兽变成植物族。
-- ③：这张卡被破坏的场合发动。给与对方为自己的墓地·除外状态的植物族怪兽数量×100伤害。被「黑蔷薇龙」的效果破坏的场合，再给与对方2400伤害。
local s,id,o=GetID()
-- 初始化卡片效果的入口函数，注册卡片效果和全局监听。
function s.initial_effect(c)
	-- 将「黑蔷薇龙」加入该卡的关联卡片密码列表中。
	aux.AddCodeList(c,73580471)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把1只「蔷薇龙」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：场上的表侧表示怪兽变成植物族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(RACE_PLANT)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被破坏的场合发动。给与对方为自己的墓地·除外状态的植物族怪兽数量×100伤害。被「黑蔷薇龙」的效果破坏的场合，再给与对方2400伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"伤害效果"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把1只「蔷薇龙」怪兽加入手卡。②：场上的表侧表示怪兽变成植物族。③：这张卡被破坏的场合发动。给与对方为自己的墓地·除外状态的植物族怪兽数量×100伤害。被「黑蔷薇龙」的效果破坏的场合，再给与对方2400伤害。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 注册全局环境效果，用于监听卡片被破坏的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局破坏事件的监听函数，用于触发自定义事件。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，通知此卡已被破坏，以便在墓地或除外状态下发动效果。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,ev)
end
-- 过滤条件：检索自己卡组或墓地中「蔷薇龙」怪兽的过滤函数。
function s.thfilter(c)
	return c:IsSetCard(0x1123) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 场地魔法卡发动时的效果处理函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组及墓地中所有满足条件的「蔷薇龙」怪兽（受「王家之谷」影响）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 若存在可检索的卡，则询问玩家是否发动该效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把「蔷薇龙」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片加入玩家手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：自己墓地或除外状态下表侧表示的植物族怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_PLANT)
end
-- 伤害效果的发动条件判断函数，并检测是否是被「黑蔷薇龙」的效果破坏。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not eg:IsContains(c) then return false end
	if not re or not re:IsActivated() then
		e:SetLabel(0)
		return true
	end
	local rc=re:GetHandler()
	if not rc then
		e:SetLabel(0)
		return true
	end
	if c:IsReason(REASON_EFFECT)
		and (eg:IsContains(re:GetHandler()) and rc:GetPreviousCodeOnField()==73580471
		or not eg:IsContains(re:GetHandler()) and rc:IsCode(73580471)) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return true
end
-- 伤害效果的目标选择与初始化函数，计算伤害数值并设置效果处理信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己墓地及除外状态的植物族怪兽数量，并乘以100作为基础伤害值。
	local dam=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)*100
	-- 设置伤害效果的对象玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	if dam>0 then
		if e:GetLabel()==1 then
			dam=dam+2400
		end
		-- 设置伤害效果的参数为计算出的伤害数值。
		Duel.SetTargetParam(dam)
		-- 设置连锁操作信息，表明此效果会给对方造成伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 伤害效果的执行函数，给予对方伤害，若满足条件则追加2400伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算自己墓地及除外状态的植物族怪兽数量×100的伤害值。
	local dam=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)*100
	if dam>0 then
		-- 对目标玩家造成基础伤害，并返回实际受到的伤害值。
		local val=Duel.Damage(p,dam,REASON_EFFECT)
		-- 若成功造成伤害、对方玩家仍有生命值且此卡是被「黑蔷薇龙」的效果破坏。
		if val>0 and Duel.GetLP(p)>0 and e:GetLabel()==1 then
			-- 中断当前效果处理，使后续的追加伤害不与前一个伤害同时处理。
			Duel.BreakEffect()
			-- 给予对方玩家2400点追加伤害。
			Duel.Damage(p,2400,REASON_EFFECT)
		end
	end
end
