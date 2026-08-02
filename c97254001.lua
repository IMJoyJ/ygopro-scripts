--夏
-- 效果：
-- ①：1回合1次，可以发动。没有使用的对方的主要怪兽区域数量的四季指示物给这张卡放置。
-- ②：1回合1次，自己怪兽的攻击宣言时才能发动。给与对方这张卡的四季指示物数量以及自己墓地的「春」数量×400伤害。
-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从手卡·卡组到自己场上表侧表示放置（这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
local s,id,o=GetID()
-- 注册卡片的基本属性和所有效果。
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名「春」。
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
	-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从手卡·卡组到自己场上表侧表示放置
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
s.mentioned_counter={
	[0x6e]=true,
}
-- 放置指示物效果的发动前检查。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有未使用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
end
-- 给这张卡放置指示物的具体处理。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给这张卡放置等于对方没有使用的主要怪兽区域数量的四季指示物。
	c:AddCounter(0x6e,Duel.GetLocationCount(1-tp,LOCATION_MZONE))
end
-- 给予伤害效果的发动条件判断。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗攻击的怪兽。
	local ac=Duel.GetAttacker()
	return ac:IsControler(tp)
end
-- 给予伤害效果的发动前检查和操作信息设置。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dam1=c:GetCounter(0x6e)
	-- 统计自己墓地中「春」的数量。
	local dam2=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,60600821)
	local dam=dam1+dam2
	if chk==0 then return dam>0 end
	-- 设置效果处理的伤害对象为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的伤害数值参数。
	Duel.SetTargetParam(dam*400)
	-- 告知系统该效果包含给予对方伤害的操作。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam*400)
end
-- 给予伤害效果的具体处理。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前设置的伤害对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam1=c:GetCounter(0x6e)
	-- 在效果处理时再次统计自己墓地中「春」的数量。
	local dam2=Duel.GetMatchingGroupCount(Card.IsCode,1-p,LOCATION_GRAVE,0,nil,60600821)
	local dam=dam1+dam2
	if dam>0 then
		-- 给与对方计算出的最终数值的伤害。
		Duel.Damage(p,dam*400,REASON_EFFECT)
	end
end
-- 放置场地魔法卡效果的发动条件判断。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否是对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 用于筛选可以放置四季指示物且可以在场地区域发动的场地魔法卡的过滤函数。
function s.stfilter(c,tp)
	return c:IsCanHaveCounter(0x6e) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 放置场地魔法卡效果的发动前检查。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在满足条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 放置场地魔法卡效果的具体处理。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的场地魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡或卡组中选择1张满足条件的场地魔法卡。
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域当前的卡片。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		local ct=0
		if fc then
			if fc==e:GetHandler() and fc:GetCounter(0x6e)>0 then
				ct=fc:GetCounter(0x6e)
			end
			-- 如果场地区域已经有卡，则将其按规则送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使旧场地送墓和新场地放置视为不同时发生。
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡在自己场区表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		-- （这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
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
