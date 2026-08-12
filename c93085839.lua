--聖騎士エクター・ド・マリス
-- 效果：
-- 「圣骑士 爱克托·德·马利斯」的①的效果1回合只能使用1次。
-- ①：把自己墓地2只「圣骑士」怪兽除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：这张卡为素材的「圣骑士」怪兽的同调召唤·超量召唤不会被无效化，在那次特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
function c93085839.initial_effect(c)
	-- 「圣骑士 爱克托·德·马利斯」的①的效果1回合只能使用1次。①：把自己墓地2只「圣骑士」怪兽除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93085839,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,93085839)
	e1:SetCost(c93085839.spcost)
	e1:SetTarget(c93085839.sptg)
	e1:SetOperation(c93085839.spop)
	c:RegisterEffect(e1)
	-- 在那次特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c93085839.effcon)
	e2:SetOperation(c93085839.effop1)
	c:RegisterEffect(e2)
	-- ②：这张卡为素材的「圣骑士」怪兽的同调召唤·超量召唤不会被无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_PRE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c93085839.effcon)
	e3:SetOperation(c93085839.effop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地的「圣骑士」怪兽且可以作为代价除外
function c93085839.spfilter(c)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：把自己墓地2只「圣骑士」怪兽除外
function c93085839.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除自身以外的2只及以上可以除外的「圣骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93085839.spfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择墓地2只满足过滤条件的「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c93085839.spfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的目标检查与操作信息设置
function c93085839.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤
function c93085839.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检查是否作为「圣骑士」怪兽的同调召唤或超量召唤的素材
function c93085839.effcon(e,tp,eg,ep,ev,re,r,rp)
	return (r==REASON_XYZ or r==REASON_SYNCHRO) and e:GetHandler():GetReasonCard():IsSetCard(0x107a)
end
-- 在素材确定时，为召唤出的怪兽注册一个在其特殊召唤成功时触发的效果
function c93085839.effop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 在那次特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetOperation(c93085839.sumop)
	rc:RegisterEffect(e1,true)
end
-- 特殊召唤成功时的处理：限制该时点对方的效果发动
function c93085839.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 限制连锁直到当前连锁结束
	Duel.SetChainLimitTillChainEnd(c93085839.chainlm)
end
-- 连锁限制条件：只有发动效果的玩家与当前玩家相同时才能发动（即对方不能发动效果）
function c93085839.chainlm(e,rp,tp)
	return tp==rp
end
-- 在将要作为素材时，为召唤出的怪兽注册“召唤不会被无效化”的效果
function c93085839.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为素材的「圣骑士」怪兽的同调召唤·超量召唤不会被无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
