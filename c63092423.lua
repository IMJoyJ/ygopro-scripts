--弾帯城壁龍
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：自己连接召唤成功时才能发动。这张卡从手卡特殊召唤，给这张卡放置2个指示物。
-- ②：双方不能把持有比这张卡的指示物数量多的数量的连接标记的怪兽连接召唤，连接怪兽以外的怪兽不能攻击。
-- ③：怪兽连接召唤的场合发动。这张卡2个指示物取除。
-- ④：自己·对方的准备阶段发动。给这张卡放置1个指示物。
function c63092423.initial_effect(c)
	c:EnableCounterPermit(0x44)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己连接召唤成功时才能发动。这张卡从手卡特殊召唤，给这张卡放置2个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63092423,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c63092423.spcon)
	e2:SetTarget(c63092423.sptg)
	e2:SetOperation(c63092423.spop)
	c:RegisterEffect(e2)
	-- ②：双方不能把持有比这张卡的指示物数量多的数量的连接标记的怪兽连接召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c63092423.splimit)
	c:RegisterEffect(e3)
	-- 连接怪兽以外的怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c63092423.atktg)
	c:RegisterEffect(e4)
	-- ③：怪兽连接召唤的场合发动。这张卡2个指示物取除。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(63092423,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c63092423.ctcon1)
	e5:SetOperation(c63092423.ctop1)
	c:RegisterEffect(e5)
	-- ④：自己·对方的准备阶段发动。给这张卡放置1个指示物。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(63092423,2))
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetOperation(c63092423.ctop2)
	c:RegisterEffect(e6)
end
-- 过滤条件：检测场上是否存在由自己连接召唤成功的表侧表示怪兽
function c63092423.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的发动条件：自己连接召唤成功时
function c63092423.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c63092423.cfilter,1,nil,tp)
end
-- 效果①的靶向/发动检测：检查怪兽区域空位、自身能否特殊召唤以及能否放置指示物
function c63092423.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查自身能否放置至少1个指示物
		and Duel.IsCanAddCounter(tp,0x44,1,e:GetHandler()) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤，并放置2个指示物，最后完成正规召唤程序
function c63092423.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍与效果相关，则将自身以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:AddCounter(0x44,2)
		c:CompleteProcedure()
	end
end
-- 限制条件：不能连接召唤连接标记数量大于这张卡指示物数量的怪兽
function c63092423.splimit(e,c,tp,sumtp,sumpos)
	return c:GetLink()>e:GetHandler():GetCounter(0x44) and bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 攻击限制对象：非连接怪兽的怪兽
function c63092423.atktg(e,c)
	return not c:IsType(TYPE_LINK)
end
-- 效果③的发动条件：有怪兽连接召唤成功
function c63092423.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_LINK)
end
-- 效果③的效果处理：取除这张卡的2个指示物
function c63092423.ctop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RemoveCounter(tp,0x44,2,REASON_EFFECT)
	end
end
-- 效果④的效果处理：给这张卡放置1个指示物
function c63092423.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x44,1)
	end
end
