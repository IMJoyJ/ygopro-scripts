--イカサマ御法度
-- 效果：
-- ①：1回合1次，对方从手卡把怪兽特殊召唤时才能发动。从手卡特殊召唤的对方场上的怪兽全部回到持有者手卡。
-- ②：场上没有「花札卫」同调怪兽存在的场合这张卡送去墓地。
function c26781870.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_SELF_TOGRAVE，使本卡②的EFFECT_SELF_TOGRAVE不入连锁送墓效果能够被引擎检测并处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方从手卡把怪兽特殊召唤时才能发动。从手卡特殊召唤的对方场上的怪兽全部回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26781870,1))  --"发动并使用①效果"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c26781870.condition)
	e2:SetTarget(c26781870.target)
	e2:SetOperation(c26781870.activate)
	c:RegisterEffect(e2)
	-- ②：场上没有「花札卫」同调怪兽存在的场合这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SELF_TOGRAVE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c26781870.sdcon)
	c:RegisterEffect(e4)
end
-- 筛选条件：判定特殊召唤成功的怪兽是否由对方玩家（1-tp）从手牌特殊召唤（其召唤前位置为手牌）。
function c26781870.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 发动条件：本次特殊召唤成功的事件组eg中存在至少1只由对方从手牌特殊召唤的怪兽。
function c26781870.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26781870.cfilter,1,nil,tp)
end
-- 筛选对方场上满足“从手卡特殊召唤而来”且“能够加入手卡”的怪兽（召唤位置为手牌、召唤类型为特殊召唤）。
function c26781870.filter(c)
	return c:IsSummonLocation(LOCATION_HAND) and c:IsAbleToHand()
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动处理：先检查对方场上是否存在符合条件的怪兽，若存在则获取这些怪兽的集合g，并设置本连锁将把g中的卡返回手牌（数量为g:GetCount()）。
function c26781870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法判定：在效果发动时（chk==0）必须存在至少1只对方场上从手卡特殊召唤且能回手的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c26781870.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足filter的怪兽集合，作为设置操作信息的对象。
	local g=Duel.GetMatchingGroup(c26781870.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将集合g中的卡返回持有者手牌，count设为g的数量，供引擎检测相关时点（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：重新获取当前对方场上所有从手卡特殊召唤且能回手的怪兽，若有则将其全部返回持有者手卡。
function c26781870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有满足filter的怪兽集合，用于实际执行回手处理。
	local g=Duel.GetMatchingGroup(c26781870.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将集合g中的卡以效果原因送回其持有者手卡（nil表示返回各自持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 筛选条件：场上表侧表示且属于「花札卫」系列（setname 0xe6）的同调怪兽。
function c26781870.sdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsType(TYPE_SYNCHRO)
end
-- 自我送墓条件：场上不存在任何表侧表示的「花札卫」同调怪兽（包括双方怪兽区域）。
function c26781870.sdcon(e)
	-- 判定场上（双方主要怪兽区域）不存在符合条件的表侧表示「花札卫」同调怪兽时返回true，从而触发②效果。
	return not Duel.IsExistingMatchingCard(c26781870.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
