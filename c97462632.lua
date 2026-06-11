--グリフォー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●这个回合，自己受到的战斗·效果伤害只有1次变成0。
-- ●从卡组把有「光与暗的仪式」的卡名记述的1张速攻魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：8星仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
local s,id,o=GetID()
-- 初始化效果：注册手卡丢弃选择发动的二速效果，以及作为8星仪式怪兽仪式召唤解放数值的效果
function s.initial_effect(c)
	-- 建立这张卡记述了卡片密码为33599853（光与暗的仪式）的关联列表
	aux.AddCodeList(c,33599853)
	-- ①：自己·对方回合，可以把这张卡从手卡丢弃，从以下效果选择1个发动。
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
	-- ②：8星仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
end
-- 手卡丢弃发动效果的Cost函数，检查并将自身送入墓地
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为Cost将这张卡从手卡送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检索卡组中记述了「光与暗的仪式」卡名且可以盖放的速攻魔法或陷阱卡
function s.setfilter(c)
	-- 判断卡片是否在卡组中记述了「光与暗的仪式」，且是速攻魔法或陷阱卡，并且当前可以盖放
	return aux.IsCodeListed(c,33599853) and (c:IsType(TYPE_QUICKPLAY) or c:IsType(TYPE_TRAP)) and c:IsSSetable()
end
-- 手卡丢弃发动效果的Target函数，检查可发动的选项，让玩家进行选择，并根据选择设置效果分类
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=true
	-- 检查卡组中是否存在满足条件的速攻魔法或陷阱卡
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从符合条件的可选效果中选择1个发动
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
-- 手卡丢弃发动效果的Operation函数，根据选择的选项分别执行伤害变0或盖放魔陷的效果
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- ●这个回合，自己受到的战斗·效果伤害只有1次变成0。 / ●从卡组把有「光与暗的仪式」的卡名记述的1张速攻魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCondition(s.damcon)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 为玩家注册全局战斗伤害变0效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetValue(1)
		-- 为玩家注册全局效果伤害变0效果
		Duel.RegisterEffect(e2,tp)
	elseif e:GetLabel()==2 then
		-- 检查当前魔法与陷阱区域是否有空位，没有则不处理
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 向玩家发送选择要盖放卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择并获取1张满足条件的速攻魔法或陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.SSet(tp,tc)>0 then
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
-- 伤害变0效果的Condition函数，检查该回合是否已适用过该伤害变0效果
function s.damcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查玩家该回合是否没有注册过该效果已生效的Flag
	return Duel.GetFlagEffect(tp,id)==0
end
-- 伤害值修改的Value函数，对战斗·效果伤害注册Flag以记为已适用1次，并把本次伤害变成0
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 then
		-- 为玩家注册本回合已适用伤害变0效果的Flag，重置时间为回合结束时
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 作为仪式祭品时的等级判定函数，如果是8星仪式怪兽的仪式召唤，可作为需要的数值的解放使用
function s.rlevel(e,c)
	-- 获取该怪兽在系统安全阈值内的等级数值
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsLevel(8) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
