--夏
-- 效果：
-- ①：1回合1次，可以发动。没有使用的对方的主要怪兽区域数量的四季指示物给这张卡放置。
-- ②：1回合1次，自己怪兽的攻击宣言时才能发动。给与对方这张卡的四季指示物数量以及自己墓地的「春」数量×400伤害。
-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从手卡·卡组到自己场上表侧表示放置（这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
local s,id,o=GetID()
-- 注册这张卡的发动效果、放置四季指示物效果、给与伤害效果以及放置场地魔法卡效果。
function s.initial_effect(c)
	-- 将「春」的卡片密码（60600821）注册到这张卡记载的卡号列表中。
	aux.AddCodeList(c,60600821)
	c:EnableCounterPermit(0x6e)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以发动。没有使用的对方的主要怪兽区域数量的四季指示物给这张卡放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己怪兽的攻击宣言时才能发动。给与对方这张卡的四季指示物数量以及自己墓地的「春」数量×400伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从手卡·卡组到自己场上表侧表示放置（这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"放置场地魔法卡"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 效果①发动的检测处理：确认对方的主要怪兽区域是否存在没有使用的空格。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认对方的主要怪兽区域是否存在至少1个可用的空格。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
end
-- 效果①的处理：给这张卡放置没有使用的对方主要怪兽区域数量的四季指示物。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给这张卡放置对方场上可用怪兽区域数量的四季指示物（0x6e）。
	c:AddCounter(0x6e,Duel.GetLocationCount(1-tp,LOCATION_MZONE))
end
-- 效果②的发动条件判定：发动宣言攻击的怪兽是自己场上的怪兽。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local ac=Duel.GetAttacker()
	return ac:IsControler(tp)
end
-- 效果②发动的靶向处理：计算伤害量并设定伤害的连锁操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dam1=c:GetCounter(0x6e)
	-- 获取自己墓地中名为「春」的怪兽的数量。
	local dam2=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,60600821)
	local dam=dam1+dam2
	if chk==0 then return dam>0 end
	-- 设置受伤害的目标玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置受伤害的参数值。
	Duel.SetTargetParam(dam*400)
	-- 设置当前连锁的操作信息：给与对方计算出的伤害值伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam*400)
end
-- 效果②的处理：给与对方玩家这张卡的四季指示物数量以及自己墓地「春」的数量之和×400的伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中获取受伤害的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam1=c:GetCounter(0x6e)
	-- 再次从发起人墓地中获取「春」的数量。
	local dam2=Duel.GetMatchingGroupCount(Card.IsCode,1-p,LOCATION_GRAVE,0,nil,60600821)
	local dam=dam1+dam2
	if dam>0 then
		-- 对目标玩家造成计算得出的效果伤害。
		Duel.Damage(p,dam*400,REASON_EFFECT)
	end
end
-- 效果③的发动条件判定：在对方的回合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件检测：确认当前的回合玩家是否不是自己（即对方的回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤手牌或卡组中可以放置四季指示物且能放置在场地区表侧表示的场地魔法卡的过滤函数。
function s.stfilter(c,tp)
	return c:IsCanHaveCounter(0x6e) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果③发动的靶向处理：确认手牌或卡组中存在符合条件的场地魔法卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认手牌或卡组中是否存在至少1张可以放置四季指示物的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果③的处理：将手牌·卡组表侧表示放置1张场地魔法卡，若原卡有指示物则移动过去，并使放置的卡本回合效果不能发动。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要表侧表示放置的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手牌或卡组中选择1张满足条件的场地魔法卡。
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场上当前存在的场地魔法卡。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		local ct=0
		if fc then
			if fc==e:GetHandler() and fc:GetCounter(0x6e)>0 then
				ct=fc:GetCounter(0x6e)
			end
			-- 根据规则将原来场上的场地魔法卡送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使前后的处理不视为同时进行。
			Duel.BreakEffect()
		end
		-- 将选中的新场地魔法卡放置到自己的场地区。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		-- 那张卡的效果在这个回合不能发动。（这张卡的四季指示物移给那张卡）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		if ct>0 and tc:IsCanAddCounter(0x6e,ct) then
			tc:AddCounter(0x6e,ct)
		end
	end
end
