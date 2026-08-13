--光の王 マルデル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「光界王战 玛多尔女王」在自己场上只能有1只表侧表示存在。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。「光界王战 玛多尔女王」以外的，1张「王战」卡或者1只植物族怪兽从卡组加入手卡。
function c13903402.initial_effect(c)
	c:SetUniqueOnField(1,0,13903402)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤成功的场合才能发动。「光界王战 玛多尔女王」以外的，1张「王战」卡或者1只植物族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13903402,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,13903402)
	e1:SetTarget(c13903402.thtg)
	e1:SetOperation(c13903402.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义检索筛选函数：从卡组中选出满足「王战」字段或植物族、卡名不为「光界王战 玛多尔女王」、且能够加入手卡的卡。
function c13903402.thfilter(c)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_PLANT)) and not c:IsCode(13903402) and c:IsAbleToHand()
end
-- 效果发动时的目标判定与操作信息设定：先检查卡组是否存在满足检索条件的卡，并设置本连锁将进行从卡组加入手卡的处理。
function c13903402.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：在卡组中确认是否存在至少1张满足检索条件的卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13903402.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预告本效果将把1张卡从卡组加入手卡，供相关卡片和规则判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择1张符合条件的卡加入手卡，并让对方确认。
function c13903402.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张符合条件的卡（不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c13903402.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
