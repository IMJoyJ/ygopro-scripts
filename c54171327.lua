--Angelechy Disturbance
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 以自己场上1只表侧表示的「Angelechy」怪兽为对象才能发动。那只怪兽的控制权直到结束阶段给对方。那个位置纵列及相邻位置的对方场上的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 把墓地的这张卡除外才能发动。从卡组把同名卡以外的1张「Angelechy」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示且控制权可以改变的「Angelechy」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1e2) and c:IsControlerCanBeChanged()
end
-- 效果①的发动条件检查：确认自己场上是否存在符合条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在可改变控制权的表侧表示「Angelechy」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 筛选位于转移控制权后怪兽相邻位置（怪兽区）或同一纵列（魔陷区）的对方卡片
function s.disfilter(c,seq)
	local seq2=c:GetSequence()
	-- 排除无法无效的卡片和场地魔法卡
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
-- 效果①的处理：把选中的自己怪兽转移控制权给对方，并使其相邻/同纵列的对方卡片效果无效化
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择改变控制权怪兽的提示框
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽控制权转移给对方直到结束阶段，并判断是否成功
	if tc and Duel.GetControl(tc,1-tp,PHASE_END,1)~=0 then
		local seq=tc:GetSequence()
		-- 获取对方场上处于该怪兽位置相邻或同纵列的所有卡片
		local sg=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_ONFIELD,nil,seq)
		if sg:GetCount()>0 then
			-- 遍历需要无效效果的对方卡片组
			for nc in aux.Next(sg) do
				-- 使目标卡已发动的连锁效果无效
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 效果无效化
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e1)
				-- 效果无效化
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					-- 效果无效化
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
-- 筛选卡组中同名卡以外的「Angelechy」魔法·陷阱卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and c:IsSetCard(0x1e2)
end
-- 效果②的目标设置：检查卡组是否存在目标卡并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「Angelechy」魔陷
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组检索卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组把1张「Angelechy」魔法·陷阱卡加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择加入手牌卡片的提示框
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「Angelechy」魔陷
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
