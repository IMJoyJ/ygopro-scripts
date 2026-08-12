--ジャンク・ジャイアント
-- 效果：
-- ①：对方场上有5星以上的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡为素材的同调召唤不会被无效化，在那次同调召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
function c34492631.initial_effect(c)
	-- ①：对方场上有5星以上的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34492631.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡为素材的同调召唤不会被无效化，在那次同调召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c34492631.effcon)
	e2:SetOperation(c34492631.effop1)
	c:RegisterEffect(e2)
	-- ②：这张卡为素材的同调召唤不会被无效化，在那次同调召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_PRE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c34492631.effcon)
	e3:SetOperation(c34492631.effop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以玩家来看的对方场上是否存在至少1张等级5以上的表侧表示怪兽
function c34492631.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 判断特殊召唤条件是否满足：玩家场上存在空位且对方场上存在等级5以上的怪兽
function c34492631.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查以玩家来看的对方场上是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c34492631.filter,tp,0,LOCATION_MZONE,1,nil)
end
-- 判断事件是否为同调召唤
function c34492631.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 当作为同调素材的怪兽特殊召唤成功时，设置对方不能发动魔法·陷阱·怪兽效果
function c34492631.effop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为素材的同调召唤不会被无效化，在那次同调召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetOperation(c34492631.sumop)
	rc:RegisterEffect(e1,true)
end
-- 设置连锁限制函数，使对方在同调召唤成功后无法发动效果
function c34492631.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制函数，使对方在同调召唤成功后无法发动效果
	Duel.SetChainLimitTillChainEnd(c34492631.chainlm)
end
-- 连锁限制函数，仅允许发动玩家自身发动的效果
function c34492631.chainlm(e,rp,tp)
	return tp==rp
end
-- 当作为同调素材的怪兽即将被用作同调召唤的素材时，设置该同调召唤不会被无效化
function c34492631.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为素材的同调召唤不会被无效化，在那次同调召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
