--魔轟神界の復活
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把「魔轰神界的复活」以外的1张「魔轰神」魔法·陷阱卡在自己场上盖放。
-- ②：只要这张卡在魔法与陷阱区域存在，在自己的「魔轰神」同调怪兽的同调召唤成功时对方不能把卡的效果发动。
-- ③：1回合1次，可以从手卡丢弃1张「魔轰神」卡，从以下效果选择1个发动。
-- ●自己抽1张。
-- ●自己的墓地·除外状态的1只「魔轰神」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动、同调召唤成功时对方效果发动限制以及丢弃手卡选择效果发动的各项效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把「魔轰神界的复活」以外的1张「魔轰神」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，在自己的「魔轰神」同调怪兽的同调召唤成功时对方不能把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，在自己的「魔轰神」同调怪兽的同调召唤成功时对方不能把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以从手卡丢弃1张「魔轰神」卡，从以下效果选择1个发动。●自己抽1张。●自己的墓地·除外状态的1只「魔轰神」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"选择效果发动"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
-- 过滤卡组中「魔轰神界的复活」以外的「魔轰神」魔法·陷阱卡且可盖放的过滤函数
function s.ssfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x35) and not c:IsCode(id) and not c:IsForbidden() and c:IsSSetable()
end
-- 卡片发动时的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(s.ssfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 若存在满足条件的卡，则询问玩家是否进行盖放
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡盖放？"
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,sg:GetFirst())
	end
end
-- 过滤自己同调召唤成功的「魔轰神」同调怪兽的过滤函数
function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0x35) and c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 判断是否在自己「魔轰神」同调怪兽同调召唤成功时发动的条件函数
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- 同调召唤成功时限制对方发动卡的效果的处理函数
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁数是否为0（即同调召唤成功时没有其他效果发动）
	if Duel.GetCurrentChain()==0 then
		-- 限制连锁直到连锁结束，使对方不能发动卡的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前连锁数是否为1（即同调召唤成功时有诱发效果发动并作为连锁1）
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ②：只要这张卡在魔法与陷阱区域存在，在自己的「魔轰神」同调怪兽的同调召唤成功时对方不能把卡的效果发动。③：1回合1次，可以从手卡丢弃1张「魔轰神」卡，从以下效果选择1个发动。●自己抽1张。●自己的墓地·除外状态的1只「魔轰神」怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册在有新连锁发动时重置标记的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册在效果处理中途断开时重置标记的全局效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标记效果并重置自身效果的处理函数
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 在连锁结束时，若存在标记则限制连锁直到连锁结束，并重置标记
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 限制连锁直到连锁结束，使对方不能发动卡的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 限制连锁的条件函数，仅允许发动效果的玩家进行连锁
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤手卡中可丢弃的「魔轰神」卡的过滤函数
function s.costfilter(c)
	return c:IsSetCard(0x35) and c:IsDiscardable()
end
-- 丢弃1张「魔轰神」卡作为发动代价的费用函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查手卡中是否存在可丢弃的「魔轰神」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张满足条件的「魔轰神」卡
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤自己墓地或除外状态的可特殊召唤的「魔轰神」怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择效果发动的目标选择与准备函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己是否可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
	-- 检查自己场上是否有空位且墓地或除外状态是否存在可特殊召唤的「魔轰神」怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and not b2 then
		-- 向对方提示自己选择了抽卡效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))  --"抽卡"
		op=1
	end
	if b2 and not b1 then
		-- 向对方提示自己选择了特殊召唤效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))  --"特殊召唤"
		op=2
	end
	if b1 and b2 then
		-- 让玩家从可用选项中选择一个效果发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3)},  --"抽卡"
			{b2,aux.Stringid(id,4)})  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置效果处理的对象玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 设置效果处理的参数为1（抽1张卡）
		Duel.SetTargetParam(1)
		-- 设置抽卡效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 执行所选效果的效果处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取目标玩家和抽卡数量等连锁信息
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 让目标玩家从卡组抽指定数量的卡
		Duel.Draw(p,d,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 检查自己场上是否有可用的怪兽区域空格，若无则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地或除外状态选择1只满足条件的「魔轰神」怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽在自己场上特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
