--M∀LICE＜C＞TB－11
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
-- ①：从卡组把1只「码丽丝」怪兽特殊召唤。对方场上有卡3张以上存在的场合，也能作为代替从额外卡组把1只「码丽丝」连接怪兽特殊召唤。这个回合，这个效果特殊召唤的怪兽不能攻击，那个效果不能发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（特殊召唤）以及在盖放回合发动的效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「码丽丝」怪兽特殊召唤。对方场上有卡3张以上存在的场合，也能作为代替从额外卡组把1只「码丽丝」连接怪兽特殊召唤。这个回合，这个效果特殊召唤的怪兽不能攻击，那个效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"适用「码丽丝<代码>TB-11」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetValue(id)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
-- 过滤满足特殊召唤条件的「码丽丝」怪兽（卡组或额外卡组）
function s.spfilter(c,e,tp,co,res)
	return c:IsSetCard(0x1bf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡片是否在卡组，且自身场上有可用的怪兽区域（若作为Cost除外了怪兽，则需考虑该怪兽离场后的格子）
		and ((c:IsLocation(LOCATION_DECK) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or res and Duel.GetMZoneCount(tp,res)>0))
		-- 检查卡片是否在额外卡组且为连接怪兽，且额外怪兽区域有空位，且对方场上的卡在3张以上
		or (c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_LINK) and Duel.GetLocationCountFromEx(tp,tp,res,c)>0 and co>2))
end
-- 效果①的发动准备与合法性检测（Target函数）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方场上的卡片数量
	local co=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local res=e:GetHandler():IsHasEffect(EFFECT_TRAP_ACT_IN_SET_TURN,tp)
	if chk==0 then return res and res:GetOwner()==c and res:GetValue()==id
		-- 检查卡组或额外卡组是否存在可特殊召唤的「码丽丝」怪兽
		or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,co,nil) end
	-- 设置特殊召唤的操作信息（从卡组或额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果①的执行处理（Activate函数）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡片数量
	local co=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只满足特殊召唤条件的「码丽丝」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,co,nil)
	local tc=g:GetFirst()
	-- 如果成功将选中的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个回合，这个效果特殊召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		-- 那个效果不能发动。这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 过滤作为在盖放回合发动Cost的、场上表侧表示的「码丽丝」怪兽
function s.cfilter(c,e,tp,co)
	return c:IsSetCard(0x1bf) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
		-- 检查除外该怪兽后，是否仍有可特殊召唤的合法目标
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,co,c)
end
-- 限制该效果只能在盖放的回合、且在场上时发动
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- 盖放回合发动的Cost处理（除外场上1只表侧表示的「码丽丝」怪兽）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡片数量
	local co=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 检查是否能支付除外1只表侧表示「码丽丝」怪兽的Cost
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,co) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只场上表侧表示的「码丽丝」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,co)
	-- 将选中的怪兽表侧表示除外作为发动Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
