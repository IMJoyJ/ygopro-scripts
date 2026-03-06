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
	-- 双方各自在1回合只能有合计最多3只怪兽从额外卡组特殊召唤。
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
		-- 抽卡阶段开始时，将双方的特殊召唤次数重置为3次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(c29724053.resetop)
		-- 将效果注册到全局环境，使该效果在游戏场地上生效。
		Duel.RegisterEffect(ge1,0)
		-- 特殊召唤成功时，检查召唤的怪兽是否来自额外卡组，若是则减少对应玩家的特殊召唤次数。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetOperation(c29724053.checkop)
		-- 将效果注册到全局环境，使该效果在游戏场地上生效。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 判断目标怪兽是否来自额外卡组且对应玩家的剩余特殊召唤次数为0，若是则禁止其特殊召唤。
function c29724053.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and c29724053[sump]<=0
end
-- 将双方的特殊召唤次数重置为3次。
function c29724053.resetop(e,tp,eg,ep,ev,re,r,rp)
	c29724053[0]=3
	c29724053[1]=3
end
-- 遍历特殊召唤成功的怪兽，若其来自额外卡组，则减少对应玩家的特殊召唤次数。
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
