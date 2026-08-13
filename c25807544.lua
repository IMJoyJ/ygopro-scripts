--大聖剣博物館
-- 效果：
-- ①：自己场上的战士族·炎属性怪兽的攻击力上升500。
-- ②：1回合1次，支付1200基本分才能发动。从卡组把「大圣剑博物馆」以外的1张「圣剑」卡加入手卡。
-- ③：这张卡的②的效果适用的回合1次，以自己的魔法与陷阱区域1张「圣骑士」怪兽卡为对象才能发动。那张卡特殊召唤。自己场上没有「焰圣骑士帝-查理」存在的状态把这个效果发动过的场合，直到回合结束时自己不是战士族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化本卡效果：创建并注册e1发动效果（使本卡能发动）、e2的①攻击力提升效果、e3的②检索效果、e4的③特殊召唤效果；同时将「焰圣骑士帝-查理」记入卡名列表。
function s.initial_effect(c)
	-- 将「焰圣骑士帝-查理」（77656797）登记为这张卡上记载的卡名，用于规则上识别效果文本中提到的该卡名。
	aux.AddCodeList(c,77656797)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的战士族·炎属性怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ②：1回合1次，支付1200基本分才能发动。从卡组把「大圣剑博物馆」以外的1张「圣剑」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡的②的效果适用的回合1次，以自己的魔法与陷阱区域1张「圣骑士」怪兽卡为对象才能发动。那张卡特殊召唤。自己场上没有「焰圣骑士帝-查理」存在的状态把这个效果发动过的场合，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetLabel(0)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- e2攻击力提升的对象筛选：该怪兽必须满足战士族且炎属性。
function s.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)
end
-- ②效果的代价函数：检查并支付1200基本分作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检查阶段：确认当前玩家是否能够支付1200基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 实际支付1200基本分，完成代价支付。
	Duel.PayLPCost(tp,1200)
end
-- 检索条件的过滤函数：从卡组选择「大圣剑博物馆」以外的1张「圣剑」系列卡，且该卡能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x207a) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ②效果的发动目标设定：确认卡组存在可检索的「圣剑」卡，并声明本次效果将进行从卡组加入手卡的操作。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：卡组中是否存在至少1张满足s.thfilter条件的「圣剑」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组加入手卡；因检索在处理时选择，故此时targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「圣剑」卡加入手卡并展示给对方，然后为本卡登记flag，记录本回合已适用过②效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示框，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足s.thfilter条件的「圣剑」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③效果的发动条件：本卡已带有flag标记，即本回合已经适用过②效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ③效果的选择对象过滤：位于自己魔法与陷阱区域、表侧表示、不在场地区、属于「圣骑士」系列、原始类型为怪兽且可以特殊召唤的卡。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and not c:IsLocation(LOCATION_FZONE) and c:IsSetCard(0x107a)
		and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断场上是否存在表侧表示的「焰圣骑士帝-查理」（77656797），用于决定是否施加特殊召唤自肃。
function s.charlesfilter(c)
	return c:IsFaceup() and c:IsCode(77656797)
end
-- ③效果的目标检查：chkc分支校验对象是否为自己魔陷区的可特召「圣骑士」怪兽；chk==0分支确认发动时有可用主要怪兽区和可选对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区是否有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己的魔法与陷阱区域是否存在至少1张满足条件的「圣骑士」怪兽卡可作为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	e:SetLabel(0)
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的魔法与陷阱区域选择1张符合条件的「圣骑士」怪兽卡，并登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将把选择的对象特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 判断自己场上是否不存在「焰圣骑士帝-查理」；若不存在，则之后需要设置自肃标记。
	if not Duel.IsExistingMatchingCard(s.charlesfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		e:SetLabel(1)
	end
end
-- ③效果处理：将对象卡特殊召唤；若发动时场上无「焰圣骑士帝-查理」，则给当前玩家附加直到回合结束不能特殊召唤战士族以外怪兽的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中登记的对象卡（要特殊召唤的「圣骑士」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 特殊召唤前检查：主要怪兽区仍有空位，且对象卡与本效果仍有联系（没有被无效或移走）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:GetLabel()==1 then
		-- 自己场上没有「焰圣骑士帝-查理」存在的状态把这个效果发动过的场合，直到回合结束时自己不是战士族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册到当前玩家，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃的目标判定：不能特殊召唤的怪兽为『不是战士族』的怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
