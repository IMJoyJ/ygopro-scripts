--バックアップ・ウォリアー
-- 效果：
-- 这张卡不能通常召唤。自己场上存在的怪兽只有守备表示怪兽2只的场合可以特殊召唤。把这张卡特殊召唤的回合，自己不能同调召唤。
function c95637655.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己场上存在的怪兽只有守备表示怪兽2只的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c95637655.spcon)
	c:RegisterEffect(e1)
	-- 把这张卡特殊召唤的回合，自己不能同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCost(c95637655.spcost)
	e2:SetOperation(c95637655.spop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于检测玩家在当前回合是否进行过同调召唤。
	Duel.AddCustomActivityCounter(95637655,ACTIVITY_SPSUMMON,c95637655.counterfilter)
end
-- 计数器的过滤函数，当特殊召唤的怪兽不是同调召唤时返回true（即同调召唤时计数器会增加）。
function c95637655.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 特殊召唤规则的条件判断函数，检查自己场上是否仅有2只守备表示怪兽且有可用怪兽区域。
function c95637655.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的怪兽数量是否刚好为2只。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==2
		-- 检查自己场上不存在攻击表示的怪兽，确保场上的怪兽全部为守备表示。
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 特殊召唤的代价判断函数，确保本回合在此之前没有进行过同调召唤。
function c95637655.spcost(e,c,tp)
	-- 检查本回合玩家进行同调召唤的次数是否为0。
	return Duel.GetCustomActivityCount(95637655,tp,ACTIVITY_SPSUMMON)==0
end
-- 特殊召唤成功时的操作函数，注册一个本回合不能进行同调召唤的玩家效果。
function c95637655.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 把这张卡特殊召唤的回合，自己不能同调召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95637655.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能同调召唤的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，用于判定并禁止同调召唤。
function c95637655.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
