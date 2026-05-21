--クリムゾン・ヘルガイア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。除「深红狱大地」外的1张「红莲魔龙」或者有那个卡名记述的卡从自己的卡组·墓地加入手卡。
-- ②：自己的「红莲魔龙」的攻击宣言时才能发动。对方场上的怪兽全部变成里侧守备表示。
-- ③：场上的怪兽被战斗·效果破坏的场合才能发动。从自己墓地把1只「红莲魔龙」特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 将「红莲魔龙」注册到这张卡的关联卡片列表中，以便其他卡片检测
	aux.AddCodeList(c,70902743)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。除「深红狱大地」外的1张「红莲魔龙」或者有那个卡名记述的卡从自己的卡组·墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己的「红莲魔龙」的攻击宣言时才能发动。对方场上的怪兽全部变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- ③：场上的怪兽被战斗·效果破坏的场合才能发动。从自己墓地把1只「红莲魔龙」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检索卡组或墓地中除「深红狱大地」以外、「红莲魔龙」或有其卡名记述的且能加入手牌的卡
function s.filter(c)
	-- 检查卡片是否为「红莲魔龙」或记述了该卡名，且能加入手牌，并且不是同名卡「深红狱大地」
	return aux.IsCodeOrListed(c,70902743) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果①的发动准备与可行性检查函数（Target）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组或墓地将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的效果处理函数（Operation），执行检索或回收
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的卡（受「王家长眠之谷」影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件函数，检查是否为自己的「红莲魔龙」进行攻击宣言
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsCode(70902743)
end
-- 效果②的发动准备与可行性检查函数（Target）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁处理的操作信息，表示该效果包含改变对方场上所有可变怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
-- 效果②的效果处理函数（Operation），将对方怪兽全部变为里侧守备表示
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上当前所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	-- 将获取到的怪兽全部变成里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
-- 过滤函数：检查被破坏的卡是否原本在怪兽区域，且是被战斗或效果破坏
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果③的发动条件函数，检查场上是否有怪兽被战斗或效果破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 过滤函数：检查墓地中是否存在可以特殊召唤的「红莲魔龙」
function s.sfilter(c,e,tp)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与可行性检查函数（Target）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在可以特殊召唤的「红莲魔龙」
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的效果处理函数（Operation），执行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给发动效果的玩家发送提示信息，提示其选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只满足特殊召唤条件的「红莲魔龙」
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
