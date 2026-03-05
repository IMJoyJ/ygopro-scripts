--幻獣王キマイラ
-- 效果：
-- 兽族怪兽＋恶魔族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「有翼幻兽 奇美拉」使用。
-- ②：这张卡融合召唤的场合才能发动。这个回合的结束阶段把对方手卡随机1张送去墓地。
-- ③：对方回合把墓地的这张卡除外，以自己墓地1只兽族·恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤限制、融合素材条件、卡名变更效果，并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只兽族怪兽和1只恶魔族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),true)
	-- 使该卡在墓地或场上时视为「有翼幻兽 奇美拉」（卡号4796100）
	aux.EnableChangeCode(c,4796100,LOCATION_GRAVE+LOCATION_MZONE)
	-- 效果①：这张卡融合召唤成功时发动，将对方手卡随机1张送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	-- 效果③：对方回合时，将此卡从墓地除外，以自己墓地1只兽族·恶魔族·幻想魔族怪兽为对象发动，将其特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件：此卡为融合召唤成功时
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果②的处理函数，注册一个结束阶段时触发的效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册结束阶段效果，用于在结束阶段时将对方手卡随机1张送去墓地
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.tgop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段效果的处理函数，随机选择对方手卡1张并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示发动了此卡的效果
	Duel.Hint(HINT_CARD,0,id)
	-- 从对方手卡中随机选择1张
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	if #g>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果③的发动条件：在对方回合时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 筛选可特殊召唤的怪兽（兽族·恶魔族·幻想魔族）
function s.filter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备阶段，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否有满足条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的处理函数，将目标怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍存在于场上，则将其特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
