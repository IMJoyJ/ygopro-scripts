--ベアルクティ－ミクポーラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把「北极天熊-小白熊」以外的1只「北极天熊」怪兽加入手卡。
function c29537493.initial_effect(c)
	-- 调用通用函数为「北极天熊-小白熊」注册①效果中“自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动，这张卡从手卡特殊召唤”的诱发即时效果，并返回该效果对象供后续设置描述与次数限制。
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(29537493,0))
	e1:SetCountLimit(1,29537493)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把「北极天熊-小白熊」以外的1只「北极天熊」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29537493,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,29537494)
	e2:SetTarget(c29537493.thtg)
	e2:SetOperation(c29537493.thop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤器：目标卡必须满足卡名属于「北极天熊」字段、是怪兽卡、不是「北极天熊-小白熊」自身，并且能够加入手卡（即不受“不能加入手卡”等限制）。
function c29537493.thfilter(c)
	return c:IsSetCard(0x163) and c:IsType(TYPE_MONSTER) and not c:IsCode(29537493) and c:IsAbleToHand()
end
-- ②效果的发动条件（Target）函数：在发动时确认卡组是否存在符合条件的「北极天熊」怪兽，若存在则允许发动，并设置本次操作信息为从卡组将1张卡加入手卡。
function c29537493.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动合法性检查）时，判断卡组中是否存在至少1张满足c29537493.thfilter过滤条件的「北极天熊」怪兽，若存在则返回true允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29537493.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁的效果类别为“加入手卡”和“检索”，将要从玩家tp的卡组把1张卡加入手卡，供后续效果连锁（如星尘龙、王家长眠之谷等）进行判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：从卡组选择1张符合条件的「北极天熊」怪兽加入手卡，并向对方玩家展示确认。
function c29537493.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示“请选择要加入手牌的卡”的选择提示框，用于引导选择要检索的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中选出1张满足c29537493.thfilter条件的「北极天熊」怪兽（不能是「北极天熊-小白熊」自身）。
	local g=Duel.SelectMatchingCard(tp,c29537493.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片以“效果”为原因送入其持有者的手卡，即完成检索加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡片展示给对方玩家（1-tp）确认，以符合规则中的公开确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
