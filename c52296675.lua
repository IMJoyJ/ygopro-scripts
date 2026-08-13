--アンカモフライト
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己的额外卡组的卡不存在的场合或者只有「迷彩光书签」的场合才能发动。这张卡破坏。那之后，自己从卡组抽1张。
-- 【怪兽效果】
-- 这张卡不能通常召唤。这张卡在额外卡组表侧表示存在，「迷彩光书签」以外的卡不在自己的额外卡组存在的场合才能特殊召唤。这个方法的「迷彩光书签」的特殊召唤1回合只能有1次。
-- ①：怪兽区域的表侧表示的这张卡从场上离开的场合除外。
function c52296675.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽属性，使其可作为灵摆卡在灵摆区发动，并可进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己的额外卡组的卡不存在的场合或者只有「迷彩光书签」的场合才能发动。这张卡破坏。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52296675,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,52296675)
	e1:SetCondition(c52296675.drcon)
	e1:SetTarget(c52296675.drtg)
	e1:SetOperation(c52296675.drop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 这张卡在额外卡组表侧表示存在，「迷彩光书签」以外的卡不在自己的额外卡组存在的场合才能特殊召唤。这个方法的「迷彩光书签」的特殊召唤1回合只能有1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,52296676+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(c52296675.hspcon)
	c:RegisterEffect(e3)
	-- 为这张卡添加离场时除外的重定向效果：当这张卡在怪兽区域表侧表示时从场上离开则除外。
	aux.AddBanishRedirect(c,c52296675.recon)
end
-- 过滤额外卡组中的卡，要求为表侧表示且卡名为「迷彩光书签」（卡号52296675）。
function c52296675.drfilter(c)
	return c:IsFaceup() and c:IsCode(52296675)
end
-- 灵摆效果的发动条件：自己的额外卡组没有卡，或额外卡组中全部是表侧表示的「迷彩光书签」时才能发动。
function c52296675.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己的额外卡组中卡片的数量。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	-- 额外卡组数量为0，或额外卡组中表侧表示的「迷彩光书签」数量等于额外卡组总数时条件成立。
	return ct==0 or ct==Duel.GetMatchingGroupCount(c52296675.drfilter,tp,LOCATION_EXTRA,0,nil)
end
-- 灵摆效果的发动目标函数：确认自己可以抽1张卡，并设置破坏这张卡和抽卡的操作信息。
function c52296675.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：若自己不能抽1张卡，则无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：破坏这张卡本身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 灵摆效果处理：先以效果破坏这张卡，成功后再抽1张卡。
function c52296675.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与效果关联，并尝试用效果破坏；只有破坏成功时才继续后续抽卡。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 中断当前效果，使破坏和抽卡不在同一时点处理，避免引起错误的连锁时点。
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 特殊召唤规则的条件：额外卡组存在且全部是表侧表示的「迷彩光书签」，同时有可用的额外怪兽区域空格。
function c52296675.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 统计自己的额外卡组的卡片数量。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	-- 额外卡组中不存在「迷彩光书签」以外的卡，且自己场上有足够空格从额外卡组特殊召唤这张卡。
	return ct==Duel.GetMatchingGroupCount(c52296675.drfilter,tp,LOCATION_EXTRA,0,nil) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 离场除外效果的触发条件：这张卡在怪兽区域表侧表示存在。
function c52296675.recon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
