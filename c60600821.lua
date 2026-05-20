--春
-- 效果：
-- ①：1回合1次，可以发动。指定没有使用的自己的主要怪兽区域任意数量，那个数量的四季指示物给这张卡放置。那些区域在这张卡存在期间不能使用。
-- ②：自己场上的怪兽的攻击力上升这张卡的四季指示物数量×400。
-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从卡组到自己场上表侧表示放置（这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
local s,id,o=GetID()
-- 注册卡片效果：①放置指示物并封锁区域，②根据指示物数量提升攻击力，③对方结束阶段从卡组放置场地魔法。
function s.initial_effect(c)
	c:EnableCounterPermit(0x6e)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以发动。指定没有使用的自己的主要怪兽区域任意数量，那个数量的四季指示物给这张卡放置。那些区域在这张卡存在期间不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽的攻击力上升这张卡的四季指示物数量×400。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从卡组到自己场上表侧表示放置（这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"放置场地魔法"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 效果①的发动准备：检查自己场上是否有可用的主要怪兽区域。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上可用的主要怪兽区域数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- 效果①的处理：让玩家选择要封锁的主要怪兽区域数量并指定具体格子，使这些格子不能使用，并给这张卡放置对应数量的四季指示物。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的主要怪兽区域数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
	if ct==0 then return end
	if ct>4 then ct=5 end
	local t={}
	for i=1,ct do
		t[i]=ct-i+1
	end
	-- 提示玩家选择要指定的主要怪兽区域。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请指定主要怪兽区域"
	-- 让玩家选择要指定的区域数量。
	local dsc=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 让玩家选择对应数量的可用主要怪兽区域。
	local dis=Duel.SelectDisableField(tp,dsc,LOCATION_MZONE,0,0xe000e0)
	e:SetLabel(dis)
	-- 在游戏界面上高亮显示被选择的区域。
	Duel.Hint(HINT_ZONE,tp,dis)
	if tp==1 then
		dis=((dis&0xffff)<<16)|((dis>>16)&0xffff)
	end
	-- 那些区域在这张卡存在期间不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetValue(dis)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	c:AddCounter(0x6e,dsc)
end
-- 计算攻击力上升值：这张卡的四季指示物数量×400。
function s.val(e,c)
	return e:GetHandler():GetCounter(0x6e)*400
end
-- 效果③的发动条件：对方的结束阶段。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：可以放置四季指示物的场地魔法卡，且在场上唯一存在。
function s.stfilter(c,tp)
	return c:IsCanHaveCounter(0x6e) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果③的发动准备：检查卡组中是否存在满足条件的场地魔法卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以放置四季指示物的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果③的处理：从卡组选择1张满足条件的场地魔法卡放置到场上，将原场地魔法卡送去墓地，并将原有的四季指示物转移到新场地魔法卡上，且该卡本回合不能发动效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足条件的场地魔法卡。
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域的卡。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		local ct=0
		if fc then
			if fc==e:GetHandler() and fc:GetCounter(0x6e)>0 then
				ct=fc:GetCounter(0x6e)
			end
			-- 根据规则将原本存在的场地魔法卡送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使后续的放置处理与送去墓地不视为同时进行。
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法卡在自己的场地区域表侧表示放置。
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
