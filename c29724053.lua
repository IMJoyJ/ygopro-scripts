--サモン・ゲート
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，双方各自在1回合只能有合计最多3只怪兽从额外卡组特殊召唤。
function c29724053.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方各自在1回合只能有合计最多3只怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c29724053.sumlimit)
	c:RegisterEffect(e2)
	-- 只要这张卡在魔法与陷阱区域存在
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(29724053)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
	if c29724053.global_check==nil then
		c29724053.global_check=true
		c29724053[0]=3
		c29724053[1]=3
		-- 双方各自在1回合只能有合计最多3只怪兽从额外卡组特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(c29724053.resetop)
		-- 将重置双方剩余特殊召唤次数的效果注册到全局，使其在每回合的抽卡阶段开始时将双方计数重置为3，实现“1回合”限制的刷新。
		Duel.RegisterEffect(ge1,0)
		-- 合计最多3只怪兽从额外卡组特殊召唤。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetOperation(c29724053.checkop)
		-- 将特殊召唤成功时的计数效果注册到全局，当怪兽从额外卡组特殊召唤成功后，将该召唤玩家的剩余次数减1。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 作为EFFECT_CANNOT_SPECIAL_SUMMON的判定条件：若被特殊召唤的怪兽来自额外卡组，且对应玩家剩余次数≤0，则禁止该特殊召唤。
function c29724053.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and c29724053[sump]<=0
end
-- 在抽卡阶段开始时，将双方的特殊召唤剩余次数重置为3，保证每回合只有合计最多3只从额外卡组特殊召唤的机会。
function c29724053.resetop(e,tp,eg,ep,ev,re,r,rp)
	c29724053[0]=3
	c29724053[1]=3
end
-- 遍历本次特殊召唤成功的所有怪兽，若其之前位于额外卡组，则将其召唤玩家的剩余次数减1，用于记录额外卡组特殊召唤的消耗次数。
function c29724053.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_EXTRA) then
			local p=tc:GetSummonPlayer()
			c29724053[p]=c29724053[p]-1
		end
		tc=eg:GetNext()
	end
end
