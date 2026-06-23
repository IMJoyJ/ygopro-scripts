--心を見通す眼
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建并注册一个激活效果，允许这张永续魔陷/场地卡通发动的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.picon)
	e2:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e2)
	-- 创建并注册一个场上效果，当满足条件时公开手牌。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_MOVE)
	e3:SetCondition(s.picon)
	e3:SetOperation(s.piopfun(LOCATION_MZONE))
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SSET)
	e4:SetOperation(s.piopfun(LOCATION_SZONE))
	c:RegisterEffect(e4)
	-- 创建并注册一个持续场上效果，在卡片移动时触发。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_ADJUST)
	e5:SetCondition(s.adjustcon)
	e5:SetOperation(s.adjustop)
	c:RegisterEffect(e5)
	-- 创建并注册一个持续场上效果，在调整阶段触发。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DISABLE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_SZONE)
	e6:SetHintTiming(0,TIMING_DRAW+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.accon)
	e6:SetTarget(s.actg)
	e6:SetOperation(s.acop)
	c:RegisterEffect(e6)
end
-- 定义cfilter函数，用于过滤正面显示且属于特定卡组的卡片。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x62)
end
-- 定义picon函数，检查是否有满足条件的卡片存在于战场或墓地中。
function s.picon(e)
	-- 返回是否存在满足s.cfilter条件（正面显示且属于指定卡组）的卡片。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 定义cfilter2函数，用于过滤正面显示的卡通怪兽。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TOON)
end
-- 定义cfilter3函数，用于过滤正面显示且属于特定卡组的魔法卡。
function s.cfilter3(c)
	return c:IsFaceupEx() and c:IsSetCard(0x62) and c:IsType(TYPE_SPELL)
end
-- 定义accon函数，检查是否满足发动效果的条件（存在卡通怪兽和指定卡组的魔法卡）。
function s.accon(e)
	-- 返回是否存在满足s.cfilter2条件（正面显示的卡通怪兽）的卡片。
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 返回是否存在满足s.cfilter3条件（正面显示且属于指定卡组的魔法卡）的卡片。
		and Duel.IsExistingMatchingCard(s.cfilter3,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 定义actg函数，用于选择目标卡片并设置操作信息。
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前连锁序号。
	local ch=Duel.GetCurrentChain()
	if ch>1 then
		-- 向玩家提示“请宣言一个卡名”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
		local g=Group.CreateGroup()
		for i=1,ch-1 do
			-- 获取连锁中触发效果的卡片。
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			g:AddCard(te:GetHandler())
		end
		local codes={}
		local ag=Group.CreateGroup()
		-- 遍历卡片组g。
		for c in aux.Next(g) do
			local code=c:GetCode()
			if not ag:IsExists(Card.IsCode,1,nil,code) then
				ag:AddCard(c)
				table.insert(codes,code)
			end
		end
		table.sort(codes)
		local afilter={codes[1],OPCODE_ISCODE}
		if #codes>1 then
			for i=2,#codes do
				table.insert(afilter,codes[i])
				table.insert(afilter,OPCODE_ISCODE)
				table.insert(afilter,OPCODE_OR)
			end
		end
		table.insert(afilter,OPCODE_NOT)
		ag:Clear()
		-- 使用unpack解包afilter数组，并用它来宣告卡牌。
		local ac=Duel.AnnounceCard(tp,table.unpack(afilter))
		-- 设置目标参数为ac。
		Duel.SetTargetParam(ac)
		-- 设置操作信息为CATEGORY_ANNOUNCE。
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	else
		-- 直接宣告一张卡片。
		local ac=Duel.AnnounceCard(tp)
		-- 设置目标参数为ac。
		Duel.SetTargetParam(ac)
		-- 设置操作信息为CATEGORY_ANNOUNCE。
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	end
end
-- 定义acop函数，用于执行效果的操作。
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 获取当前连锁的目标参数。
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 创建并注册一个持续场上效果，在连锁解决时无效化指定卡片的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetLabel(ac,fid)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册e1效果到tp玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义discon函数，用于检查是否满足无效化效果的条件。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac,fid=e:GetLabel()
	local ec=e:GetLabelObject()
	return ec:IsFaceupEx()
		and ec:GetFlagEffectLabel(id)==fid
		and re:GetHandler():IsOriginalCodeRule(ac)
end
-- 定义disop函数，用于使连锁效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev的效果无效。
	Duel.NegateEffect(ev)
end
-- 定义adjustcon函数，用于检查是否满足调整阶段效果的条件。
function s.adjustcon(e)
	-- 返回是否存在满足s.cfilter条件（正面显示且属于指定卡组）的卡片。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():GetFlagEffect(id+o)==0
end
-- 定义setfilter函数，用于过滤反面朝上的卡片。
function s.setfilter(c)
	return c:IsFacedown()
end
-- 定义adjustop函数，用于确认目标卡片并注册Flag效果。
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足s.setfilter条件的卡片组。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 向玩家确认选定的卡片。
	Duel.ConfirmCards(tp,g)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 定义cffilter函数，用于过滤反面朝上、在场上且由指定玩家控制的卡片。
function s.cffilter(c,tp,loc)
	return c:IsFacedown() and c:IsOnField() and c:IsControler(tp) and c:IsLocation(loc)
end
-- 定义piopfun函数，返回一个匿名函数，用于过滤并确认卡片。
function s.piopfun(loc)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local sg=eg:Filter(s.cffilter,nil,1-e:GetHandlerPlayer(),loc)
		-- 向玩家确认选定的卡片。
		Duel.ConfirmCards(tp,sg)
	end
end
