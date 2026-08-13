--S－Force グラビティーノ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「治安战警队 引力微子」以外的1张「治安战警队」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽从场上离开的场合除外。
function c21368442.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「治安战警队 引力微子」以外的1张「治安战警队」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21368442,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21368442)
	e1:SetTarget(c21368442.thtg)
	e1:SetOperation(c21368442.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c21368442.rmtg)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于检索「治安战警队」卡，要求是「治安战警队」系列卡、卡名不是「治安战警队 引力微子」，并且能够加入手卡。
function c21368442.thfilter(c)
	return c:IsSetCard(0x156) and not c:IsCode(21368442) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设定：在发动时先确认卡组中有满足 thfilter 的卡，然后设置本次操作将1张卡从卡组加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH）。
function c21368442.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：在效果发动时（chk==0）检查己方卡组是否存在至少1张满足 thfilter 的「治安战警队」卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21368442.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预声明效果处理时将1张卡从卡组加入手卡，并标明目标玩家为 tp、位置为卡组，供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1张满足 thfilter 的「治安战警队」卡，将其加入手卡，并让对手确认，完成检索。
function c21368442.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：向玩家 tp 提示“请选择要加入手牌的卡”，用于检索时的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择：让玩家 tp 从卡组中筛选并选择1张满足 thfilter 的「治安战警队」卡作为检索目标。
	local g=Duel.SelectMatchingCard(tp,c21368442.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因加入手卡（nil 表示加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示被检索的卡，使对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断怪兽是否为表侧表示、属于「治安战警队」系列、位于主要怪兽区且控制者为指定玩家，用于检查同纵列是否存在己方「治安战警队」怪兽。
function c21368442.rmfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ②效果联动判定：当有怪兽即将离场时，检查与其同纵列的卡中是否存在己方表侧表示「治安战警队」怪兽；若存在，则将该离场怪兽改为除外。
function c21368442.rmtg(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsExists(c21368442.rmfilter,1,nil,e:GetHandlerPlayer())
end
