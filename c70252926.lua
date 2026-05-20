--フォーチュンレディ・エヴァリー
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力变成这张卡的等级×400。
-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。那之后，可以选对方场上1只表侧表示怪兽除外。
-- ③：对方结束阶段有这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只魔法师族怪兽除外才能发动。这张卡特殊召唤。
function c70252926.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的魔法师族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_SPELLCASTER),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力变成这张卡的等级×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c70252926.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。那之后，可以选对方场上1只表侧表示怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70252926,0))  --"等级上升1星"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c70252926.lvcon)
	e3:SetOperation(c70252926.lvop)
	c:RegisterEffect(e3)
	-- ③：对方结束阶段有这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只魔法师族怪兽除外才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(70252926,1))  --"这张卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,70252926)
	e4:SetCondition(c70252926.spcon)
	e4:SetCost(c70252926.spcost)
	e4:SetTarget(c70252926.sptg)
	e4:SetOperation(c70252926.spop)
	c:RegisterEffect(e4)
end
-- 计算并返回这张卡的等级×400的数值
function c70252926.value(e,c)
	return c:GetLevel()*400
end
-- 准备阶段等级上升效果的发动条件函数
function c70252926.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤对方场上可以被除外的表侧表示怪兽
function c70252926.rmfilter(c)
	return c:IsAbleToRemove() and c:IsFaceup()
end
-- 准备阶段等级上升及除外效果的处理函数
function c70252926.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星（最多到12星）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 获取对方场上所有可以被除外的表侧表示怪兽
	local sg=Duel.GetMatchingGroup(c70252926.rmfilter,tp,0,LOCATION_MZONE,nil)
	-- 如果存在可除外的怪兽，询问玩家是否选择除外
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(70252926,2)) then  --"是否除外对方怪兽？"
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local tg=sg:Select(tp,1,1,nil)
		-- 中断当前效果，使后续的除外处理与等级上升不视为同时处理
		Duel.BreakEffect()
		-- 将选中的对方怪兽表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 墓地特殊召唤效果的发动条件函数
function c70252926.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤自己墓地中除自身以外的、可以作为Cost除外的魔法师族怪兽
function c70252926.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER)
end
-- 墓地特殊召唤效果的Cost处理函数
function c70252926.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除自身以外的魔法师族怪兽可以作为Cost除外
	if chk==0 then return Duel.IsExistingMatchingCard(c70252926.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中除自身以外的1只魔法师族怪兽
	local tg=Duel.SelectMatchingCard(tp,c70252926.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的魔法师族怪兽表侧表示除外作为发动Cost
	Duel.Remove(tg,POS_FACEUP,REASON_COST)
end
-- 墓地特殊召唤效果的目标选择与发动检测函数
function c70252926.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的效果处理函数
function c70252926.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
