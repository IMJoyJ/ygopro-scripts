--サイコトラッカー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「念力循轨人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：这张卡为同调素材的同调怪兽的攻击力上升600。
function c30227494.initial_effect(c)
	-- ①：自己场上有「念力循轨人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,30227494+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c30227494.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡为同调素材的同调怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c30227494.atkcon)
	e2:SetOperation(c30227494.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的3星怪兽（不包括念力循轨人）
function c30227494.sprfilter(c)
	return c:IsFaceup() and c:IsLevel(3) and not c:IsCode(30227494)
end
-- 判断特殊召唤条件是否满足：场上存在3星怪兽且有空场
function c30227494.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的3星怪兽
		and Duel.IsExistingMatchingCard(c30227494.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断是否因同调召唤而成为素材
function c30227494.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 将同调怪兽的攻击力上升600
function c30227494.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为同调怪兽增加攻击力效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
