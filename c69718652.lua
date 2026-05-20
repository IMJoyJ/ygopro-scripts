--聖霊獣騎 ノチウドラゴ
-- 效果：
-- 「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己的场上·墓地的上记的卡除外的场合才能特殊召唤。自己对「圣灵兽骑 星龙」1回合只能有1次特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的其他的「灵兽」怪兽作为效果的对象。
-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
local s,id,o=GetID()
-- 初始化效果注册函数，设置同名卡一回合一次特殊召唤限制、正规召唤限制、融合素材、接触融合手续以及注册三个效果。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- 设定融合素材为「灵兽使」怪兽和「精灵兽」怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10b5),aux.FilterBoolFunction(Card.IsFusionSetCard,0x20b5),true)
	-- 设定接触融合的特殊召唤手续：将自己场上·墓地的素材正面表示除外。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己的场上·墓地的上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的其他的「灵兽」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.etlimit)
	-- 限制不能成为对方卡的效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤不能被选择为对象的卡：自身以外的、场上表侧表示的「灵兽」怪兽。
function s.etlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0xb5)
end
-- 效果②的发动代价（Cost）函数：确认自身是否能回到额外卡组，并将自身送回额外卡组。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将作为发动代价的这张卡送回额外卡组。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤可以作为特殊召唤目标的卡：除外状态的、表侧表示的「灵兽」怪兽，且该卡可以被特殊召唤。
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xb5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）函数：检查怪兽区域空位、是否存在合法的除外状态「灵兽」怪兽，并选择该怪兽作为效果对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查在自身离开场后是否有可用的怪兽区域，以及自己除外状态是否存在至少1只满足条件的「灵兽」怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只除外状态的「灵兽」怪兽作为效果对象。
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	-- 设置连锁信息，表明该效果包含特殊召唤该对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果②的效果处理（Operation）函数：将选择的怪兽特殊召唤，并对其施加“不能直接攻击”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象怪兽。
	local tc=Duel.GetTargetsRelateToChain():GetFirst()
	if not tc then return end
	-- 将目标怪兽以表侧表示特殊召唤，若特殊召唤失败则结束处理。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 这个效果特殊召唤的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))  --"「圣灵兽骑 星龙」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
end
