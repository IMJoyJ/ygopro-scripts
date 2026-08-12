--アンカーボルト・ヘッジホッグ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，这张卡在墓地存在，除「地脚螺丝刺猬」外的「废品战士」或者有那个卡名记述的怪兽在自己场上存在的场合才能发动。这张卡守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册卡片效果，将「废品战士」加入卡名列表，并创建、配置、注册①效果
function s.initial_effect(c)
	-- 将「废品战士」（卡号60800381）记录在此卡的效果文本记载卡名列表中
	aux.AddCodeList(c,60800381)
	-- ①：自己·对方回合，这张卡在墓地存在，除「地脚螺丝刺猬」外的「废品战士」或者有那个卡名记述的怪兽在自己场上存在的场合才能发动。这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示存在的、除「地脚螺丝刺猬」以外的「废品战士」或有其卡名记述的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsCode(id)
		-- 检查卡片是否为「废品战士」或者其效果文本中记载了「废品战士」的怪兽
		and (c:IsCode(60800381) or aux.IsCodeListed(c,60800381) and c:IsType(TYPE_MONSTER))
end
-- 发动条件：自己场上存在满足过滤条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 发动目标：检查怪兽区域是否有空位，以及此卡是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息，目标为自身，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤，并适用“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁相关，且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该不能从额外卡组特殊召唤同调以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤：限制从额外卡组特殊召唤非同调怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
