--心を見通す眼
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡通用的发动效果、公开手牌效果、场地区域内卡片翻面效果和诱发即时效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个影响对方手牌区域的公开手牌效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.picon)
	e2:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REVEAL_ONFIELD)
	-- 设置该效果的目标为场上所有背面朝上的卡片
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFacedown))
	e3:SetTargetRange(0,LOCATION_ONFIELD)
	c:RegisterEffect(e3)
	-- 创建一个诱发即时效果，用于在特定条件下使对方效果无效
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
-- 过滤函数，判断场上是否有名字带有“心”字的怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x62)
end
-- 条件函数，判断是否满足发动条件（存在名字带有“心”字的怪兽）
function s.picon(e)
	-- 检查是否存在名字带有“心”字的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数，判断场上是否有卡通怪兽
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TOON)
end
-- 过滤函数，判断场上是否有名字带有“心”字的魔法卡
function s.cfilter3(c)
	return c:IsFaceupEx() and c:IsSetCard(0x62) and c:IsType(TYPE_SPELL)
end
-- 条件函数，判断是否满足发动条件（存在卡通怪兽和名字带有“心”字的魔法卡）
function s.accon(e)
	-- 检查是否存在卡通怪兽
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 检查是否存在名字带有“心”字的魔法卡
		and Duel.IsExistingMatchingCard(s.cfilter3,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 设置效果目标处理逻辑，根据连锁数量决定是否需要宣言卡名并设置操作信息
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前正在处理的连锁序号
	local ch=Duel.GetCurrentChain()
	if ch>1 then
		-- 向玩家发送提示信息，提示其选择一个卡名
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
		local g=Group.CreateGroup()
		for i=1,ch-1 do
			-- 获取指定连锁中触发的效果
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			g:AddCard(te:GetHandler())
		end
		local codes={}
		local ag=Group.CreateGroup()
		-- 遍历卡片组中的每张卡片
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
		-- 让玩家宣言一个符合过滤条件的卡名
		local ac=Duel.AnnounceCard(tp,table.unpack(afilter))
		-- 将宣言的卡号设置为当前连锁的目标参数
		Duel.SetTargetParam(ac)
		-- 设置操作信息，表示需要进行卡名宣言的操作
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	else
		-- 让玩家宣言任意一张卡名
		local ac=Duel.AnnounceCard(tp)
		-- 将宣言的卡号设置为当前连锁的目标参数
		Duel.SetTargetParam(ac)
		-- 设置操作信息，表示需要进行卡名宣言的操作
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	end
end
-- 设置效果处理逻辑，注册一个持续效果用于在连锁解决时使对方效果无效
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 获取当前连锁的目标参数
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 创建一个持续效果，用于在连锁解决时判断是否需要使效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetLabel(ac,fid)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将该持续效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 条件函数，判断是否满足使效果无效的条件（目标怪兽处于正面状态且为同一张卡、触发效果的原始卡号匹配）
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac,fid=e:GetLabel()
	local ec=e:GetLabelObject()
	return ec:IsFaceupEx()
		and ec:GetFlagEffectLabel(id)==fid
		and re:GetHandler():IsOriginalCodeRule(ac)
end
-- 操作函数，使指定连锁的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理的连锁效果无效
	Duel.NegateEffect(ev)
end
