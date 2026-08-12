--幻奏の音姫スペクタキュラー・バッハ
-- 效果：
-- 「幻奏」怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「幻奏」怪兽特殊召唤。
-- ②：只要融合召唤的这张卡在怪兽区域存在，自己的「幻奏」融合怪兽发动的效果不会被无效化。
-- ③：这张卡被送去墓地的场合，以「幻奏的音姬 壮丽之巴赫」以外的自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册融合召唤手续以及①②③效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要2只「幻奏」怪兽作为素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x9b),2,true)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「幻奏」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要融合召唤的这张卡在怪兽区域存在，自己的「幻奏」融合怪兽发动的效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.inacon)
	e2:SetValue(s.effectfilter)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以「幻奏的音姬 壮丽之巴赫」以外的自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg1)
	e3:SetOperation(s.spop1)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以特殊召唤的「幻奏」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与效果处理目标检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「幻奏」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理，从卡组特殊召唤1只「幻奏」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「幻奏」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若选出卡片，则将其以表侧表示特殊召唤
	if g:GetCount()>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的启用条件，此卡必须是融合召唤的
function s.inacon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤不受无效化影响的效果，必须是自己发动的「幻奏」融合怪兽的效果
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取当前处理的连锁的效果和发动玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(0x9b) and te:IsActiveType(TYPE_FUSION)
end
-- 过滤墓地中除同名卡以外、可以守备表示特殊召唤的「幻奏」怪兽
function s.spfilter1(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的发动条件、对象检测与目标选择
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在可以特殊召唤的、除同名卡以外的「幻奏」怪兽
		and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择墓地中1只满足条件的「幻奏」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表示将特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的实际处理，将选中的对象怪兽守备表示特殊召唤
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象怪兽
	local tc=Duel.GetTargetsRelateToChain()
	-- 若对象怪兽仍合法，则将其守备表示特殊召唤
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
end
