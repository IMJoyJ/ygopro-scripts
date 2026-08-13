--春
-- 效果：
-- ①：1回合1次，可以发动。指定没有使用的自己的主要怪兽区域任意数量，那个数量的四季指示物给这张卡放置。那些区域在这张卡存在期间不能使用。
-- ②：自己场上的怪兽的攻击力上升这张卡的四季指示物数量×400。
-- ③：对方结束阶段才能发动。可以放置四季指示物的1张场地魔法卡从卡组到自己场上表侧表示放置（这张卡的四季指示物移给那张卡）。那张卡的效果在这个回合不能发动。
local s,id,o=GetID()
-- 初始化效果：允许放置四季指示物，注册可自由时点发动的空效果（使这张场地魔法卡可以发动）、①放置指示物的起动效果（1回合1次）、②攻击力上升的永续效果、③对方结束阶段放置场地魔法的诱发选发效果
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
s.mentioned_counter={
	[0x6e]=true,
}
-- ①效果的发动条件检查：确认自己的主要怪兽区域存在没有使用的空格
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否有至少1个没有使用的空格，没有则不能发动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- ①效果的处理：让自己宣言要指定的主要怪兽区域数量，选择相应数量的未使用主要怪兽区域使其在这张卡存在期间不能使用，并给这张卡放置那个数量的四季指示物
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得自己主要怪兽区域没有使用的空格数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
	if ct==0 then return end
	if ct>4 then ct=5 end
	local t={}
	for i=1,ct do
		t[i]=ct-i+1
	end
	-- 提示玩家「请指定主要怪兽区域」
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请指定主要怪兽区域"
	-- 让玩家宣言要指定的主要怪兽区域的数量（1到可用空格数）
	local dsc=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 让玩家选择宣言数量的没有使用的自己的主要怪兽区域，返回所选区域的标记
	local dis=Duel.SelectDisableField(tp,dsc,LOCATION_MZONE,0,0xe000e0)
	e:SetLabel(dis)
	-- 以高亮区域的方式向对方提示所指定的主要怪兽区域
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
-- 计算攻击力上升数值：这张卡的四季指示物数量×400
function s.val(e,c)
	return e:GetHandler():GetCounter(0x6e)*400
end
-- ③效果的发动条件：当前回合玩家不是自己，即对方回合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 只有对方回合（结束阶段）才能发动
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤器：可以放置四季指示物的场地魔法卡，且未被禁止使用、满足场上唯一性限制
function s.stfilter(c,tp)
	return c:IsCanHaveCounter(0x6e) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ③效果的目标检查：确认卡组存在可以放置四季指示物的场地魔法卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足条件的场地魔法卡，不存在则不能发动
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ③效果的处理：从卡组选1张可以放置四季指示物的场地魔法卡，将原场地区的卡（这张卡）按规则送去墓地，把选的卡在自己场上表侧表示放置，那张卡的效果在这个回合不能发动，并把这张卡的四季指示物移给那张卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家「请选择要放置到场上的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1张满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 取得自己场地区域（魔法·陷阱区域5号位）现有的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		local ct=0
		if fc then
			if fc==e:GetHandler() and fc:GetCounter(0x6e)>0 then
				ct=fc:GetCounter(0x6e)
			end
			-- 按规则把原场地区的卡送去墓地（场地魔法替换的规则处理）
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使之后的处理与送去墓地视为不同时处理
			Duel.BreakEffect()
		end
		-- 把选择的场地魔法卡在自己场上的场地区域表侧表示放置
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
