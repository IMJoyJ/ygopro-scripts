--心を見通す眼
local s,id,o=GetID()
-- 注册此卡发动时的效果处理、手牌公开及确认里侧表示卡、以及无效宣言卡名效果的3个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上或墓地有「卡通」卡存在，对方手牌全部持续公开
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.picon)
	e2:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REVEAL_ONFIELD)
	-- 设置确认卡片效果的对象为里侧表示的卡
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFacedown))
	e3:SetTargetRange(0,LOCATION_ONFIELD)
	c:RegisterEffect(e3)
	-- ②：自己场上·墓地有卡通怪兽以及「卡通」魔法卡存在的场合，可以宣言1个在同一连锁上没有把效果发动的卡名并发动
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
-- 过滤条件：自己场上或墓地表侧表示存在的「卡通」卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x62)
end
-- 效果①的发动条件（Condition）：检查自己场上或墓地是否存在「卡通」卡
function s.picon(e)
	-- 检查自己场上或墓地是否存在至少1张满足过滤条件的「卡通」卡
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 过滤条件：自己场上或墓地表侧表示存在的卡通怪兽
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TOON)
end
-- 过滤条件：自己场上或墓地表侧表示存在的「卡通」魔法卡
function s.cfilter3(c)
	return c:IsFaceupEx() and c:IsSetCard(0x62) and c:IsType(TYPE_SPELL)
end
-- 效果②的Condition条件函数：检查自己场上或墓地是否有卡通怪兽以及「卡通」魔法卡存在
function s.accon(e)
	-- 检查自己场上或墓地是否存在至少1只卡通怪兽
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 检查自己场上或墓地是否存在至少1张「卡通」魔法卡
		and Duel.IsExistingMatchingCard(s.cfilter3,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 效果②的Target函数：获取并在同一连锁中排除已发动效果的卡名，让玩家宣言1个剩余的卡名并作为效果对象参数
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前的连锁数
	local ch=Duel.GetCurrentChain()
	if ch>1 then
		-- 给玩家发送请宣言卡名的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
		local g=Group.CreateGroup()
		for i=1,ch-1 do
			-- 获取当前连锁中第i个连锁触发的效果
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			g:AddCard(te:GetHandler())
		end
		local codes={}
		local ag=Group.CreateGroup()
		-- 遍历连锁中已触发效果的卡片组
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
		-- 让玩家从符合过滤条件的卡名中宣言1个卡名
		local ac=Duel.AnnounceCard(tp,table.unpack(afilter))
		-- 将宣言的卡号存入效果对象参数中
		Duel.SetTargetParam(ac)
		-- 设置当前连锁的操作信息为包含宣言分类
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	else
		-- 让玩家宣言任意1个卡名
		local ac=Duel.AnnounceCard(tp)
		-- 将宣言的卡号存入效果对象参数中
		Duel.SetTargetParam(ac)
		-- 设置当前连锁的操作信息为包含宣言分类
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	end
end
-- 效果②的Operation函数：注册直到回合结束时使宣言的卡名发动的效果无效的持续型场上效果
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 获取效果发动时玩家所宣言的卡名
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 直到回合结束时，宣言的卡名与元卡名相同的卡所发动的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetLabel(ac,fid)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在系统全局注册该无效效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 无效效果的Condition条件函数：检查本卡是否在场上表侧表示存在，且正在处理的效果的发动者的原始卡名与宣言的卡名相同
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac,fid=e:GetLabel()
	local ec=e:GetLabelObject()
	return ec:IsFaceupEx()
		and ec:GetFlagEffectLabel(id)==fid
		and re:GetHandler():IsOriginalCodeRule(ac)
end
-- 无效效果的Operation函数：使当前处理的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁上的效果无效
	Duel.NegateEffect(ev)
end
