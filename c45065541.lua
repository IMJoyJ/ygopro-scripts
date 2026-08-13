--伍世壊摘心
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「伍世坏-喜悦世界」加入手卡。自己场上有「伍世坏-喜悦世界」存在的场合，也能作为代替把「伍世坏摘心」以外的1张「末那愚子族」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：为本卡注册两个效果。效果1是魔法卡发动效果，破坏自己场上1只怪兽并检索「伍世坏-喜悦世界」或满足条件的「末那愚子族」魔法·陷阱卡；效果2是墓地起动效果，除外自身并从手卡特殊召唤符合条件的怪兽。
function s.initial_effect(c)
	-- 将卡名中记载的「维萨斯-斯塔弗罗斯特」和「伍世坏-喜悦世界」登记到本卡的代码列表中，供“这张卡上记载着另一张卡名”等判定使用。
	aux.AddCodeList(c,56099748,82460246)
	-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「伍世坏-喜悦世界」加入手卡。自己场上有「伍世坏-喜悦世界」存在的场合，也能作为代替把「伍世坏摘心」以外的1张「末那愚子族」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 为效果2设置COST：使用辅助函数aux.bfgcost，即把墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断场上是否存在表侧表示的「伍世坏-喜悦世界」（卡号82460246），用于检测“自己场上有「伍世坏-喜悦世界」存在”这一条件。
function s.filter1(c)
	return c:IsFaceup() and c:IsCode(82460246)
end
-- 检索目标过滤函数：要求不是本卡「伍世坏摘心」，并且可以是「伍世坏-喜悦世界」；若check为真（自己场上有「伍世坏-喜悦世界」），也可以是「末那愚子族」的魔法·陷阱卡，且该卡必须能加入手牌。
function s.thfilter(c,check)
	local b1=c:IsCode(82460246)
	local b2=check and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x190)
	return not c:IsCode(id) and (b1 or b2) and c:IsAbleToHand()
end
-- 效果1的发动条件判定：先校验对象是否为自己场上的怪兽；再检测自己场上是否有「伍世坏-喜悦世界」（check）；在chk==0时确认存在可选对象的怪兽，且卡组中存在满足检索条件的卡，满足发动条件。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检测自己场上（包含怪兽区和魔陷区）是否存在表侧表示的「伍世坏-喜悦世界」，结果保存到check变量，用于后续检索范围判断。
	local check=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil)
	-- 当chk==0（发动合法性检查阶段）时，确认自己场上存在至少1只可作为对象的怪兽（用于破坏）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 并且卡组中存在至少1张满足s.thfilter筛选的卡（check影响是否允许检索「末那愚子族」魔法·陷阱卡）。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,check) end
	-- 给当前玩家显示选择消息，提示正在选择要破坏的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：当前连锁将进行1次破坏处理，对象为g（确定对象），用于“破坏”相关效果的发动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：当前连锁将进行从卡组将1张卡加入手卡的检索处理，对象待定，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的处理函数：取得对象，若对象仍与效果关联则将其破坏；破坏成功后重新检查场上是否有「伍世坏-喜悦世界」，然后从卡组选择1张符合条件的卡加入手牌并向对方展示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽（自己场上的1只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 如果对象与效果失去关联（如已离场），或破坏处理失败（返回0），则不再执行后续检索。
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	-- 破坏处理成功后，重新确认自己场上是否有表侧表示的「伍世坏-喜悦世界」，以决定检索范围是否包含「末那愚子族」魔法·陷阱卡。
	local check=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil)
	-- 显示‘请选择要加入手牌的卡’的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足s.thfilter条件的卡（check控制是否可检索代替品）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,check)
	if #g==0 then return end
	-- 将选择的卡以效果原因送去持有者手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家确认所检索的卡（展示加入手牌的卡）。
	Duel.ConfirmCards(1-tp,g)
end
-- 特殊召唤对象的过滤函数：手牌中的卡是「维萨斯-斯塔弗罗斯特」（56099748）或攻击力1500且守备力2100的怪兽，并且能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	return (b1 or b2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动条件判定：主怪兽区有空位，并且手牌中存在满足s.spfilter的特殊召唤候选。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用空格（避免无法特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手牌中存在至少1只满足特殊召唤条件的怪兽（s.spfilter过滤，附加e和tp参数）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：当前连锁包含从手牌特殊召唤1只怪兽，对象待定，位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果2的实际处理：若主怪兽区有空位，则从手牌选择1只符合条件的怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主怪兽区有空余位置，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示‘请选择要特殊召唤的卡’的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足s.spfilter的怪兽（附加e和tp参数作为额外过滤参数）。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽特殊召唤到自己的主要怪兽区，表示形式为表侧表示；不忽略召唤条件和苏生限制（sumtype=0, nocheck=false, nolimit=false）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
