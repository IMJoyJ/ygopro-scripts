--サイコトラッカー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「念力循轨人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：这张卡为同调素材的同调怪兽的攻击力上升600。
function c30227494.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「念力循轨人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
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
-- 过滤条件：自己场上的表侧表示、等级3、且卡名不是「念力循轨人」的怪兽，用于判定①特殊召唤所需的存在条件。
function c30227494.sprfilter(c)
	return c:IsFaceup() and c:IsLevel(3) and not c:IsCode(30227494)
end
-- ①特殊召唤的规则条件：仅在自身处于手牌且没有被其他效果无效时，若自己主怪兽区有空位，并且自己场上有表侧表示、等级3、卡名不是「念力循轨人」的怪兽存在，则允许从手卡进行规则特殊召唤；c==nil时视为规则召唤条件询问。
function c30227494.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区空位，以确定能否把这张卡从手卡特殊召唤到场上。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张满足sprfilter的怪兽（表侧表示、等级3、卡名不是「念力循轨人」），满足①特殊召唤的条件。
		and Duel.IsExistingMatchingCard(c30227494.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 诱发条件：这张卡被用作同调素材时（原因判定为REASON_SYNCHRO）触发②效果。
function c30227494.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 效果处理：取得这张卡作为素材后同调召唤出的那只怪兽，给它赋予攻击力上升600的永续效果；该效果在该怪兽离场、被送去额外卡组/手卡/墓地等标准重置时机后消失。
function c30227494.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为同调素材的同调怪兽的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
