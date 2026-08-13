--WW－フリーズ・ベル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上的怪兽只有「风魔女」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。这张卡的等级上升1星。
-- ③：用这张卡为同调素材把风属性同调怪兽同调召唤的场合，那只同调怪兽不会被战斗破坏。
function c20246864.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上的怪兽只有「风魔女」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20246864,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,20246864)
	e1:SetCondition(c20246864.spcon)
	e1:SetTarget(c20246864.sptg)
	e1:SetOperation(c20246864.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。这张卡的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20246864,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c20246864.lvtg)
	e2:SetOperation(c20246864.lvop)
	c:RegisterEffect(e2)
	-- ③：用这张卡为同调素材把风属性同调怪兽同调召唤的场合，那只同调怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c20246864.efcon)
	e3:SetOperation(c20246864.efop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定怪兽是否为表侧表示且属于「风魔女」（0xf0）字段的怪兽。
function c20246864.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf0)
end
-- ①效果的发动条件：自己场上存在怪兽，且自己场上的全部怪兽都是表侧表示的「风魔女」怪兽。
function c20246864.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有怪兽的集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 判断自己场上怪兽数量大于0，且场上怪兽数量等于满足「风魔女」条件的怪兽数量，即自己场上的怪兽只有「风魔女」怪兽。
	return #g>0 and #g==Duel.GetMatchingGroupCount(c20246864.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- ①效果发动时的目标判定：检查自己场上是否有空余的主要怪兽区域，以及这张卡自身能否被特殊召唤。
function c20246864.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区域（Duel.GetLocationCount>0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：本效果将特殊召唤这张卡（数量1），供后续效果联动判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤到自己场上。
function c20246864.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动时的目标判定：确认这张卡当前等级不低于1星（保证可以执行上升1星的操作）。
function c20246864.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(1) end
end
-- ②效果处理：若这张卡仍与效果关联且表侧表示，则为它注册一个等级上升1星的持续效果。
function c20246864.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③效果的触发条件：这张卡作为同调素材被使用，且因同调召唤出的怪兽是风属性。
function c20246864.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- ③效果处理：为同调召唤出的那只风属性同调怪兽赋予“不会被战斗破坏”的效果。
function c20246864.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：用这张卡为同调素材把风属性同调怪兽同调召唤的场合，那只同调怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20246864,2))  --"「风魔女-冻铃」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
