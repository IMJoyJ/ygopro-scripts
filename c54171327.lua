--Angelechy Disturbance
-- 效果：
-- 自己场上1只「具象天使」怪兽的控制权直到回合结束时转移给对方，那之后，那只怪兽相邻的怪兽区域或者魔法·陷阱卡区域有表侧表示的对方卡存在的场合，那些卡的效果无效化。
-- 可以从自己墓地把这张卡除外；从卡组把「具象天使之乱」以外的1张「具象天使」魔法·陷阱卡加入手卡。
-- 「具象天使之乱」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册两个效果：e1为魔陷发动型自由时点效果，转移自己场上「具象天使」怪兽的控制权并无效相邻的对方卡，1回合1次；e2为墓地发动的诱发即时效果，从卡组检索「具象天使」魔法·陷阱卡加入手卡，1回合1次，cost为把墓地的这张卡除外
function s.initial_effect(c)
	-- 自己场上1只「具象天使」怪兽的控制权直到回合结束时转移给对方，那之后，那只怪兽相邻的怪兽区域或者魔法·陷阱卡区域有表侧表示的对方卡存在的场合，那些卡的效果无效化。「具象天使之乱」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"转移控制权"
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 可以从自己墓地把这张卡除外；从卡组把「具象天使之乱」以外的1张「具象天使」魔法·陷阱卡加入手卡。「具象天使之乱」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设定效果的cost为把自己墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示、可以转移控制权的「具象天使」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1e2) and c:IsControlerCanBeChanged()
end
-- 发动条件检测：确认自己怪兽区域存在至少1只满足条件的「具象天使」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己怪兽区域是否存在至少1只表侧表示且可以改变控制权的「具象天使」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤函数：筛选位于转移控制权的那只怪兽相邻的怪兽区域或魔法·陷阱卡区域、表侧表示且可以被无效的对方卡（场地卡除外；主要怪兽区按相邻序号判断，额外怪兽区对应其下方主怪兽区，魔法·陷阱卡区域则要求同纵列）
function s.disfilter(c,seq)
	local seq2=c:GetSequence()
	-- 排除不能被无效化的卡以及场地魔法卡
	if not aux.NegateAnyFilter(c) or c:IsType(TYPE_FIELD) then return false end
	if c:IsLocation(LOCATION_MZONE) then
		if seq2<5 then
			return math.abs(seq-seq2)==1
		else
			return seq2==5 and seq==1 or seq2==6 and seq==3
		end
	else
		return seq==seq2
	end
end
-- 效果处理：让自己选择1只「具象天使」怪兽，将其控制权直到回合结束时转移给对方；若成功，则取得该怪兽相邻区域上表侧表示的对方卡，逐张使其效果无效化（含效果无效、效果发动无效及陷阱怪兽的无效处理）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家提示「请选择要改变控制权的怪兽」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让自己从怪兽区域选择1只表侧表示且可转移控制权的「具象天使」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的那只怪兽的控制权直到回合结束时转移给对方，并确认转移成功
	if tc and Duel.GetControl(tc,1-tp,PHASE_END,1)~=0 then
		local seq=tc:GetSequence()
		-- 取得那只怪兽相邻的怪兽区域或魔法·陷阱卡区域上所有表侧表示且可被无效的对方卡
		local sg=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_ONFIELD,nil,seq)
		if sg:GetCount()>0 then
			-- 逐张遍历上述筛出的对方卡
			for nc in aux.Next(sg) do
				-- 使与转移控制权的那只怪兽相关的连锁无效化（作为无效化处理的辅助步骤）
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 那些卡的效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e1)
				-- 那些卡的效果无效化。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					-- 那些卡的效果无效化（陷阱怪兽的场合同样无效化）。
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					nc:RegisterEffect(e3)
				end
			end
		end
	end
end
-- 过滤函数：筛选卡组中「具象天使之乱」以外、可以加入手卡的「具象天使」魔法·陷阱卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and c:IsSetCard(0x1e2)
end
-- 检索效果的对象检测：确认卡组存在满足条件的卡，并设置将从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张「具象天使之乱」以外的「具象天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让自己从卡组选择1张「具象天使之乱」以外的「具象天使」魔法·陷阱卡加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1张满足条件的「具象天使」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
