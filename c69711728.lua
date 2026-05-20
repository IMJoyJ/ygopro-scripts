--メタルフォーゼ・コンビネーション
-- 效果：
-- ①：1回合1次，融合怪兽融合召唤的场合，以比那融合怪兽等级低的自己墓地1只「炼装」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1只「炼装」怪兽加入手卡。
function c69711728.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，融合怪兽融合召唤的场合，以比那融合怪兽等级低的自己墓地1只「炼装」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69711728,1))  --"发动并使用①效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetTarget(c69711728.target)
	e2:SetOperation(c69711728.activate)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1只「炼装」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69711728,2))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c69711728.thcon)
	e4:SetTarget(c69711728.thtg)
	e4:SetOperation(c69711728.thop)
	c:RegisterEffect(e4)
end
-- 过滤融合召唤成功的融合怪兽，并确认自己墓地是否存在等级比其低的「炼装」怪兽
function c69711728.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION)
		-- 检查自己墓地是否存在至少1只等级比该融合怪兽低、且可以作为效果对象特殊召唤的「炼装」怪兽
		and Duel.IsExistingTarget(c69711728.filter,tp,LOCATION_GRAVE,0,1,nil,c:GetLevel(),e,tp)
end
-- 过滤自己墓地中等级比指定数值低、属于「炼装」系列且可以特殊召唤的怪兽
function c69711728.filter(c,lv,e,tp)
	return c:GetLevel()>0 and c:GetLevel()<lv and c:IsSetCard(0xe1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与合法性检测，包括判断是否已在同一连锁中发动过、是否存在融合召唤成功的融合怪兽以及自己场上是否有空余的怪兽区域
function c69711728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c69711728.filter(chkc,eg:GetFirst():GetLevel(),e,tp) end
	if chk==0 then return e:GetHandler():GetFlagEffect(69711728)==0
		and eg:IsExists(c69711728.cfilter,1,nil,e,tp)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	e:GetHandler():RegisterFlagEffect(69711728,RESET_CHAIN,0,1)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只等级比融合召唤的怪兽低的「炼装」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69711728.filter,tp,LOCATION_GRAVE,0,1,1,nil,eg:GetFirst():GetLevel(),e,tp)
	-- 设置连锁信息，表明该效果包含将选中的1只怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的处理，将作为对象的怪兽特殊召唤
function c69711728.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否是从场上送去墓地，作为②号效果的发动条件
function c69711728.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中属于「炼装」系列的怪兽卡
function c69711728.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②号效果的发动准备，确认卡组中是否存在可检索的「炼装」怪兽并设置连锁信息
function c69711728.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以加入手卡的「炼装」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69711728.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表明该效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理，从卡组选择1只「炼装」怪兽加入手卡并给对方确认
function c69711728.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「炼装」怪兽
	local g=Duel.SelectMatchingCard(tp,c69711728.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
