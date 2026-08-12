--神樹のパラディオン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：自己场上的「圣像骑士」怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
function c91646304.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,91646304+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c91646304.spcon)
	e1:SetValue(c91646304.spval)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：自己场上的「圣像骑士」怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,91646305)
	e2:SetTarget(c91646304.reptg)
	e2:SetValue(c91646304.repval)
	e2:SetOperation(c91646304.repop)
	c:RegisterEffect(e2)
end
-- 判断自身特殊召唤的条件是否满足
function c91646304.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家场上所有连接怪兽指向的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 判断在连接怪兽指向的区域中是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 定义特殊召唤的参数（召唤位置和区域）
function c91646304.spval(e,c)
	-- 返回特殊召唤的目标玩家（自己场上）以及可召唤的区域（连接怪兽指向的区域）
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- 过滤满足代替破坏条件的卡：自己场上表侧表示的「圣像骑士」怪兽，因战斗或效果被破坏，且当前不是代替破坏
function c91646304.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x116) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶向判断：检查是否有符合条件的「圣像骑士」怪兽将被破坏，且此卡自身可以被除外、未处于预定破坏状态
function c91646304.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c91646304.repfilter,1,c,tp) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定哪些卡适用此代替破坏效果
function c91646304.repval(e,c)
	return c91646304.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的操作：将此卡除外
function c91646304.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为代替的此卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
