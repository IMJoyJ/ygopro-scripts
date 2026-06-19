--天叢雲之巳剣
-- 效果：
-- 「巳剑降临」降临
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方场上的怪兽全部破坏。
-- ②：对方把效果发动时才能发动。对方可以选1张手卡丢弃。没丢弃的场合，那个效果无效化。
-- ③：这张卡被解放的场合才能发动。从卡组把「天丛云之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：设置关联卡片代码，注册仪式召唤怪兽的苏生限制以及①、②、③效果
function s.initial_effect(c)
	-- 在卡片关联代码列表中添加「巳剑降临」的卡片密码，表示此卡是与「巳剑降临」相关的卡
	aux.AddCodeList(c,81560239)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时才能发动。对方可以选1张手卡丢弃。没丢弃的场合，那个效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES_OPPO+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合才能发动。从卡组把「天丛云之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 设置①效果发动的靶向信息：检查对方场上是否存在怪兽，设置破坏对方场上全部怪兽的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测模式，检查对方场上是否存在至少1只怪兽作为合法的效果对象
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的全部怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置效果分类为破坏对方场上全部怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果①处理：破坏对方场上的全部怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 通过效果破坏获取到的对方场上全部怪兽
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 判断②效果发动条件：对方把效果发动时，且该效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认触发连锁的玩家为对方，且该连锁效果是可以被无效的
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 设置②效果发动的靶向信息，此效果在发动时不需进行特定操作或设定靶向
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- ②效果处理：对方可以选择丢弃1张手卡，若未丢弃则将该发动效果无效化
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方手牌有可以丢弃的卡且对方选择丢弃手牌，则执行丢弃手牌的操作，否则将该效果无效
	if Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then  --"是否丢弃手卡？"
		-- 让对方玩家选择自己的一张手卡丢弃
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	else
		-- 将对方发动的该连锁效果无效化
		Duel.NegateEffect(ev)
	end
end
-- 过滤条件：卡组中除「天丛云之巳剑」以外且可以加入手牌的「巳剑」卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- 设置③效果发动的靶向信息，根据发动时的卡片位置决定是否需要追加墓地特殊召唤效果分类的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测模式，检查自己卡组是否存在至少1张除「天丛云之巳剑」以外的「巳剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果分类为从卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ③效果处理：从卡组选择1张符合条件的「巳剑」卡片加入手卡，之后玩家可以选择是否特殊召唤此卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张除「天丛云之巳剑」以外的「巳剑」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片向对方展示确认
		Duel.ConfirmCards(1-tp,g)
		-- 判断自己场上是否有空余的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToEffect(e)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查自身卡片是否不受「王家长眠之谷」的影响（以防此卡处于墓地）
			and aux.NecroValleyFilter()(c)
			-- 让玩家选择是否特殊召唤此卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否特殊召唤？"
			-- 中断当前效果，使得特殊召唤与加入手牌的处理不被视为同时进行
			Duel.BreakEffect()
			-- 将此卡以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
