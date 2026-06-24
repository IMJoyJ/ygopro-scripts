--心を見通す眼
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--check hand cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.picon)
	e2:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e2)
	--check set cards
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REVEAL_ONFIELD)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFacedown))
	e3:SetTargetRange(0,LOCATION_ONFIELD)
	c:RegisterEffect(e3)
	--disable
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMING_DRAW+TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.accon)
	e4:SetTarget(s.actg)
	e4:SetOperation(s.acop)
	c:RegisterEffect(e4)
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
