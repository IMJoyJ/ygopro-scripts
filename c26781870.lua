--イカサマ御法度
-- 效果：
-- ①：1回合1次，对方从手卡把怪兽特殊召唤时才能发动。从手卡特殊召唤的对方场上的怪兽全部回到持有者手卡。
-- ②：场上没有「花札卫」同调怪兽存在的场合这张卡送去墓地。
function c26781870.initial_effect(c)
	-- 设置全局标记，用于检测自身送入墓地的情况
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
-- 过滤函数：检查怪兽是否为对方从手卡特殊召唤
function c26781870.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 效果条件：确认是否有对方从手卡特殊召唤的怪兽
function c26781870.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26781870.cfilter,1,nil,tp)
end
-- 过滤函数：检查怪兽是否为从手卡特殊召唤且可以送回手卡
function c26781870.filter(c)
	return c:IsSummonLocation(LOCATION_HAND) and c:IsAbleToHand()
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果目标：检索满足条件的对方场上的怪兽
function c26781870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26781870.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c26781870.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将要送回手卡的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将满足条件的怪兽送回手卡
function c26781870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c26781870.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将怪兽送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数：检查是否为场上的「花札卫」同调怪兽
function c26781870.sdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsType(TYPE_SYNCHRO)
end
-- 效果条件：判断场上是否存在「花札卫」同调怪兽
function c26781870.sdcon(e)
	-- 判断场上是否不存在「花札卫」同调怪兽
	return not Duel.IsExistingMatchingCard(c26781870.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
