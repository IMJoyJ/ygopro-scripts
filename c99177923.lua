--インフェルニティ・デーモン
-- 效果：
-- ①：自己手卡是0张的状态，把这张卡抽到时，把这张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤时才能发动（这个效果在自己手卡是0张的场合才能发动和处理）。从卡组把1张「永火」卡加入手卡。
function c99177923.initial_effect(c)
	-- ①：自己手卡是0张的状态，把这张卡抽到时，把这张卡给对方观看才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99177923,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c99177923.spcon)
	e1:SetCost(c99177923.spcost)
	e1:SetTarget(c99177923.sptg)
	e1:SetOperation(c99177923.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤时才能发动（这个效果在自己手卡是0张的场合才能发动和处理）。从卡组把1张「永火」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99177923,1))  --"检索卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c99177923.srcon)
	e2:SetTarget(c99177923.srtg)
	e2:SetOperation(c99177923.srop)
	c:RegisterEffect(e2)
end
-- 该效果为①效果的触发条件判定：判断这次抽卡是否满足“自己手卡是0张的状态下抽到这张卡”，即抽卡前手牌为0、本次抽卡数量等于当前手牌数且抽到的卡组中包含这张卡。
function c99177923.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己当前的手卡数量，用于与本次抽卡数量比较以确认抽卡前手牌为0。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	return ev==ct and eg:IsContains(c)
end
-- 发动代价判定：检查这张手卡是否尚未公开，满足“把这张卡给对方观看”这一代价的发动前提。
function c99177923.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 特殊召唤的目标阶段检查：确认自己场上有可用的主要怪兽区域，且这张卡可以被特殊召唤。
function c99177923.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自己场上存在至少1个可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将执行特殊召唤，对象为这张卡，预定数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理阶段：若这张卡仍在场上（与效果的关联关系正确），则执行特殊召唤。
function c99177923.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的触发条件判定：自己手卡为0张。
function c99177923.srcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己当前手卡数是否为0，用于②效果的发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 检索用的卡片过滤器：该卡必须是「永火」系列卡且可以被加入手卡。
function c99177923.filter(c)
	return c:IsSetCard(0xb) and c:IsAbleToHand()
end
-- ②效果的发动条件与检索目标设定：确认卡组中存在满足条件的「永火」卡，并记录本次操作对应“加入手牌/检索”的分类。
function c99177923.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「永火」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c99177923.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理时将从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的具体操作：若处理时自己手牌仍为0，则从卡组选择1张「永火」卡加入手牌，并展示给对方确认。
function c99177923.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时自检：若此时自己手牌数已不是0，则效果不处理，体现“自己手卡是0张的场合才能发动和处理”的限制。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then return end
	-- 弹出“请选择要加入手牌的卡”的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张满足条件的「永火」卡。
	local g=Duel.SelectMatchingCard(tp,c99177923.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（此处加入自己手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的「永火」卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
