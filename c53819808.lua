--六武院
-- 效果：
-- 每次名字带有「六武众」的怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。对方场上表侧表示存在的怪兽的攻击力下降这张卡放置的武士道指示物数量×100的数值。
function c53819808.initial_effect(c)
	c:EnableCounterPermit(0x3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次名字带有「六武众」的怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c53819808.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 对方场上表侧表示存在的怪兽的攻击力下降这张卡放置的武士道指示物数量×100的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c53819808.val)
	c:RegisterEffect(e4)
end
c53819808.counter_add_list={0x3}
-- 过滤函数，检查怪兽是否为表侧表示且名字带有「六武众」。
function c53819808.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 当有名字带有「六武众」的怪兽召唤或特殊召唤成功时，给这张卡放置1个武士道指示物。
function c53819808.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c53819808.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x3,1)
	end
end
-- 返回场上武士道指示物数量乘以-100的值，用于降低对方怪兽攻击力。
function c53819808.val(e)
	return e:GetHandler():GetCounter(0x3)*-100
end
