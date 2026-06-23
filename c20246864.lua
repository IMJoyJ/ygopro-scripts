--WW－フリーズ・ベル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上的怪兽只有「风魔女」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。这张卡的等级上升1星。
-- ③：用这张卡为同调素材把风属性同调怪兽同调召唤的场合，那只同调怪兽不会被战斗破坏。
function c20246864.initial_effect(c)
	-- ①：自己场上的怪兽只有「风魔女」怪兽的场合才能发动。这张卡从手卡特殊召唤。
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
-- 过滤函数，用于判断场上是否存在「风魔女」怪兽
function c20246864.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf0)
end
-- 效果条件函数，判断自己场上是否只有「风魔女」怪兽
function c20246864.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 判断自己场上的怪兽数量大于0且等于「风魔女」怪兽数量
	return #g>0 and #g==Duel.GetMatchingGroupCount(c20246864.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- 效果目标函数，判断是否满足特殊召唤条件
function c20246864.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息，确定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c20246864.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 等级提升效果的目标函数，判断是否满足等级提升条件
function c20246864.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(1) end
end
-- 等级提升效果的处理函数，为自身等级加1
function c20246864.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 为自身等级加1的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否因同调召唤而成为素材且素材为风属性
function c20246864.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- 效果处理函数，使同调召唤的风属性怪兽不会被战斗破坏
function c20246864.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 使同调召唤的风属性怪兽不会被战斗破坏的效果
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
