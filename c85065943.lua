--聖アザミナ
-- 效果：
-- 6星以上的融合怪兽＋6星以上的同调怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能把这张卡以及对方的场上·墓地·除外状态的卡作为效果的对象，自己受到的战斗伤害由对方代受。
-- ②：这张卡融合召唤的自己·对方回合才能发动。从卡组·额外卡组把1只9星以下的「蓟花」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册融合召唤手续、不能成为效果对象、伤害反射以及融合召唤回合从卡组·额外卡组特殊召唤「蓟花」怪兽的效果
function s.initial_effect(c)
	-- 添加融合召唤手续，需要6星以上的融合怪兽和6星以上的同调怪兽各1只
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，对方不能把这张卡以及对方的场上·墓地·除外状态的卡作为效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetTarget(s.efftg)
	-- 设置不能成为对方（即非这张卡控制者）的效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 自己受到的战斗伤害由对方代受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- ②：这张卡融合召唤的自己·对方回合才能发动。从卡组·额外卡组把1只9星以下的「蓟花」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material_type=TYPE_SYNCHRO
-- 过滤融合素材1：等级6以上的融合怪兽
function s.mfilter1(c)
	return c:IsLevelAbove(6) and c:IsFusionType(TYPE_FUSION)
end
-- 过滤融合素材2：等级6以上的同调怪兽
function s.mfilter2(c)
	return c:IsLevelAbove(6) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 过滤不能被对方作为效果对象的卡：这张卡自身，或者对方（非这张卡控制者）场上、墓地、除外的卡
function s.efftg(e,c)
	return c==e:GetHandler() or c:GetControler()~=e:GetHandlerPlayer()
end
-- 效果②的发动条件：这张卡融合召唤成功的自己或对方回合
function s.spcon(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
		and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
-- 过滤卡组或额外卡组中满足特殊召唤条件的9星以下「蓟花」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1bc) and c:IsLevelBelow(9)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若卡片在卡组，则需要自己场上有可用的怪兽区域
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，则需要有可用于从额外卡组特殊召唤的怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果②的发动准备：检查是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组或额外卡组是否存在至少1只满足条件的9星以下「蓟花」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果②的效果处理：从卡组或额外卡组选择1只9星以下的「蓟花」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的「蓟花」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
