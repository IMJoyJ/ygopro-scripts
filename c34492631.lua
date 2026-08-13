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
	-- ②：在那次同调召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c34492631.effcon)
	e2:SetOperation(c34492631.effop1)
	c:RegisterEffect(e2)
	-- ②：这张卡为素材的同调召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_PRE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c34492631.effcon)
	e3:SetOperation(c34492631.effop2)
	c:RegisterEffect(e3)
end
-- 筛选条件：表侧表示且等级为5星以上的怪兽，用于判断对方场上是否存在满足①效果的怪兽。
function c34492631.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- ①效果的规则处理：若c为nil表示规则询问返回true；否则需我方主要怪兽区有空位，且对方场上有表侧表示5星以上的怪兽。
function c34492631.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否存在空格，以决定能否从手卡进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只表侧表示且等级5星以上的怪兽，满足①效果的前置条件。
		and Duel.IsExistingMatchingCard(c34492631.filter,tp,0,LOCATION_MZONE,1,nil)
end
-- 判定本卡作为同调召唤的素材（r为REASON_SYNCHRO），从而触发②效果。
function c34492631.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 当本卡作为同调素材时，为同调召唤出来的怪兽注册一个在特殊召唤成功时触发的效果，该效果将设置连锁限制以禁止对方发动效果。
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
-- 特殊召唤成功的处理操作：设置本次连锁直到连锁结束的连锁限制，用于限制对方发动效果。
function c34492631.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 为该连锁设置一个持续到连锁结束的限制条件，所有玩家必须通过chainlm的判定才能发动效果。
	Duel.SetChainLimitTillChainEnd(c34492631.chainlm)
end
-- 连锁限制判定：仅当发动效果的玩家与触发连锁的玩家相同（tp==rp）时才允许发动，从而拒绝对方玩家发动任何效果。
function c34492631.chainlm(e,rp,tp)
	return tp==rp
end
-- 当本卡作为同调素材时（在特殊召唤成功前），为将要同调召唤的怪兽赋予“同调召唤不会被无效化”的持续效果。
function c34492631.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为素材的同调召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
