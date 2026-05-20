--アブソリュートサイキッカー
-- 效果：
-- 念动力族同调怪兽＋同调怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合，支付2000基本分才能发动。对方场上的表侧表示卡全部除外。
-- ②：这张卡只要在怪兽区域存在，不会被效果破坏。
-- ③：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从额外卡组把1只念动力族·10星融合怪兽当作融合召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果（注册融合召唤手续、特殊召唤限制、融合召唤成功时除外对方场上表侧表示卡的效果、不会被效果破坏的永续效果、从墓地除外特殊召唤额外卡组念动力族10星融合怪兽的效果）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为：念动力族同调怪兽＋同调怪兽
	aux.AddFusionProcFun2(c,s.ffilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_SYNCHRO),true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：这张卡融合召唤的场合，支付2000基本分才能发动。对方场上的表侧表示卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.rmcon)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从额外卡组把1只念动力族·10星融合怪兽当作融合召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e3:SetCondition(aux.exccon)
	-- 设置发动代价：将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material_type=TYPE_SYNCHRO
-- 融合素材过滤条件：念动力族且是同调怪兽
function s.ffilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 限制从额外卡组特殊召唤时必须是融合召唤
function s.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 效果①的发动条件：这张卡融合召唤成功
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的发动代价：检查并支付2000基本分
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 效果①的目标过滤与操作信息注册：检查对方场上是否存在可以除外的表侧表示卡，并注册除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以除外的表侧表示卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以除外的表侧表示卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD,nil)
	-- 注册连锁处理时的操作信息：除外上述获取的卡片组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 效果①的效果处理：将对方场上所有表侧表示的卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有可以除外的表侧表示卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD,nil)
	-- 将获取的卡片组以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 效果③的特殊召唤目标过滤：额外卡组中可以进行融合召唤、且可以特殊召唤的念动力族10星融合怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PSYCHO) and c:IsLevel(10) and c:CheckFusionMaterial()
		-- 过滤条件：该卡可以当作融合召唤特殊召唤，且额外怪兽区域或有连接端指向的区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的目标过滤与操作信息注册：检查是否满足素材限制，以及额外卡组是否存在符合条件的怪兽，并注册特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为融合素材的卡片限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的念动力族10星融合怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 注册连锁处理时的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：从额外卡组选择1只满足条件的念动力族10星融合怪兽，当作融合召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查必须作为融合素材的卡片限制，若不满足则不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的念动力族10星融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽以表侧表示、当作融合召唤特殊召唤，并判断是否特殊召唤成功
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
end
