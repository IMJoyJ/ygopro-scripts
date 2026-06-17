--グリフォー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●这个回合，自己受到的战斗·效果伤害只有1次变成0。
-- ●从卡组把有「光与暗的仪式」的卡名记述的1张速攻魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：8星仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
local s,id,o=GetID()
-- 初始化效果，注册两个效果：①丢弃发动效果和②仪式召唤时可作为8星怪兽的解放
function s.initial_effect(c)
	-- 记录该卡具有「光与暗的仪式」的卡名记述
	aux.AddCodeList(c,33599853)
	-- 效果①：自己·对方回合，可以把这张卡从手卡丢弃，从以下效果选择1个发动。●这个回合，自己受到的战斗·效果伤害只有1次变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"丢弃发动效果"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	-- 效果②：8星仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
end
-- 丢弃发动效果的费用处理函数，检查是否可以丢弃此卡并执行丢弃操作
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡送入墓地作为发动效果的代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 盖放卡片的过滤函数，用于筛选卡组中具有「光与暗的仪式」记述且为速攻魔法或陷阱卡的可盖放卡片
function s.setfilter(c)
	-- 检查卡片是否具有「光与暗的仪式」记述、类型为速攻魔法或陷阱卡，并且可以盖放
	return aux.IsCodeListed(c,33599853) and (c:IsType(TYPE_QUICKPLAY) or c:IsType(TYPE_TRAP)) and c:IsSSetable()
end
-- 效果选择处理函数，根据玩家选择决定发动哪个效果
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=true
	-- 检测卡组中是否存在满足条件的可盖放卡片
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从两个选项中选择一个效果发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"伤害改变"
			{b2,aux.Stringid(id,2),2})  --"盖放魔陷"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 效果发动处理函数，根据选择的选项执行对应效果
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 选项1的效果：使自己受到的战斗·效果伤害在本回合内仅发生一次变为0，并且无效化该次伤害
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCondition(s.damcon)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册伤害改变效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetValue(1)
		-- 注册伤害无效化效果
		Duel.RegisterEffect(e2,tp)
	elseif e:GetLabel()==2 then
		-- 检查场上是否有足够的魔法陷阱区域进行盖放
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择一张满足条件的卡片
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		-- 将选中的卡片盖放到场上
		if tc and Duel.SSet(tp,tc)>0 then
			-- 为盖放的卡片注册效果，使其在盖放回合也能发动
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))  --"适用「栗球兽卫」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			if tc:IsType(TYPE_QUICKPLAY) then
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			end
			if tc:IsType(TYPE_TRAP) then
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			end
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 伤害改变效果的触发条件函数，判断是否已使用过该效果
function s.damcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查玩家是否已经使用过该效果
	return Duel.GetFlagEffect(tp,id)==0
end
-- 伤害值修改函数，当受到战斗或效果伤害时将伤害设为0并标记已使用
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 then
		-- 注册标识效果，标记该玩家在本回合已使用过此效果
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 仪式召唤等级计算函数，用于判断是否可以作为8星怪兽的解放
function s.rlevel(e,c)
	-- 获取卡片等级并限制其不超过系统上限
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsLevel(8) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
