--トリックスター・ノーブルエンジェル
-- 效果：
-- 「淘气仙星」怪兽2只
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「蓝泪」卡加入手卡。
-- ②：自己的场上或墓地有融合怪兽存在的场合，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：自己或对方受到效果伤害的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 为这张卡添加连接召唤手续（2只「淘气仙星」怪兽）和苏生限制，然后依次创建并注册①检索「蓝泪」、②苏生「淘气仙星」、③破坏场上表侧表示卡这三个效果；各效果均通过SetCountLimit设置为1回合只能使用1次。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只「淘气仙星」字段的连接怪兽（0xfb）作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfb),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「蓝泪」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索「蓝泪」卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的场上或墓地有融合怪兽存在的场合，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"苏生效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己或对方受到效果伤害的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡以连接召唤方式特殊召唤成功时才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的检索过滤器：从卡组选择1张「蓝泪」字段（0x1b5）且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1b5) and c:IsAbleToHand()
end
-- ①效果的发动条件检查和目标设定：发动时确认卡组存在满足条件的「蓝泪」卡，并设置本次操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法判定：自己卡组中是否存在至少1张满足s.thfilter的「蓝泪」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为从卡组将1张卡加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：由玩家从卡组选择1张「蓝泪」卡，加入手牌并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组筛选并选择1张满足s.thfilter的「蓝泪」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）加入其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）展示选中的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的判定过滤器：判断一张卡是否为表侧表示的融合怪兽（用于检查场上或墓地是否存在融合怪兽）。
function s.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- ②效果的发动条件：自己场上或墓地存在至少1只满足s.cfilter的融合怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上或墓地是否存在至少1只表侧表示的融合怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- ②效果的特殊召唤对象过滤器：从自己墓地选择1只「淘气仙星」字段（0xfb）怪兽，且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象目标设定与发动合法判定：处理对象选择；发动时确认自己主要怪兽区有空位，且墓地存在满足s.spfilter的「淘气仙星」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区拥有至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只可作为对象的「淘气仙星」怪兽（满足s.spfilter）。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足s.spfilter的「淘气仙星」怪兽，并将其选定为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将对象怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁已选定的对象怪兽（墓地那只「淘气仙星」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示（POS_FACEUP）特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：造成伤害的事件原因是效果伤害（r的REASON_EFFECT位不为0）时才能发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- ③效果的取对象目标设定与发动合法判定：处理对象选择；发动时选择场上1张表侧表示卡，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动合法判定：场上存在至少1张表侧表示的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择双方场上的1张表侧表示卡，并将其选定为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将破坏对象卡（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：取得对象卡，若仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁已选定的对象卡（场上表侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
