--巨大戦艦 ブラスターキャノン・コア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。给这张卡放置3个指示物。
-- ③：这张卡不会被战斗破坏。
-- ④：这张卡进行战斗的伤害步骤结束时发动。这张卡1个指示物取除。不能取除的场合，这张卡破坏。
function c84257883.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,84257883+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c84257883.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。给这张卡放置3个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84257883,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c84257883.cttg)
	e2:SetOperation(c84257883.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 注册巨大战舰系列怪兽在战斗后移除指示物或破坏的通用效果（对应④效果）。
	aux.EnableBESRemove(c)
end
-- 特殊召唤规则的条件判定函数。
function c84257883.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上的怪兽数量是否比自己场上的怪兽多。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 放置指示物效果的发动准备与目标确认函数。
function c84257883.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理为放置3个指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 放置指示物效果的执行函数，为这张卡放置3个指示物。
function c84257883.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
