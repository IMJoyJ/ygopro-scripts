--GMX - ALLOS
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 「GMX-异特人龙」的以下效果1回合各能使用1次。
-- 可以以自己墓地·除外状态的1只「GMX」怪兽或者恐龙族怪兽为对象；那只怪兽特殊召唤。这个效果发动的回合，这张卡不能攻击。
-- 这张卡和对方怪兽进行战斗的伤害步骤开始时：可以把那只对方怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、对方召唤·特召时回复基本分、墓地·除外怪兽特召、伤害步骤开始时破坏对方怪兽的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为1只「GMX」怪兽和1只恐龙族怪兽。
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.reccon)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 可以以自己墓地·除外状态的1只「GMX」怪兽或者恐龙族怪兽为对象；那只怪兽特殊召唤。这个效果发动的回合，这张卡不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 这张卡和对方怪兽进行战斗的伤害步骤开始时：可以把那只对方怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"破坏对方怪兽"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件1：属于「GMX」字段的怪兽。
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材过滤条件2：恐龙族怪兽。
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤召唤·特殊召唤的怪兽是否由对方玩家进行。
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 回复效果的发动条件：对方成功召唤·特殊召唤了怪兽。
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 回复效果的处理：自己回复200基本分。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上提示发动了该卡的效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 使自己回复200基本分。
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 特殊召唤效果的Cost：检查本回合是否未宣言攻击，并适用本回合不能攻击的限制。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 可以以自己墓地·除外状态的1只「GMX」怪兽或者恐龙族怪兽为对象；那只怪兽特殊召唤。这个效果发动的回合，这张卡不能攻击。这张卡和对方怪兽进行战斗的伤害步骤开始时：可以把那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
-- 过滤自己墓地或除外状态、可以特殊召唤的「GMX」怪兽或恐龙族怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target：检查怪兽区域空位，并选择自己墓地或除外状态的1只「GMX」怪兽或恐龙族怪兽作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或除外状态是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外状态的1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽组和数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的Operation：将选择的对象怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对应的第一个对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与连锁相关，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的Target：获取进行战斗的对方怪兽，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	-- 设置破坏的操作信息，包含进行战斗的对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 破坏效果的Operation：将进行战斗的对方怪兽破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) and tc:IsType(TYPE_MONSTER) then
		-- 将进行战斗的对方怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
