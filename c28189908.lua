--TG－ブレイクリミッター
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：丢弃1张手卡才能发动。从卡组把2只「科技属」怪兽加入手卡（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽回到卡组。自己场上有机械族「科技属」怪兽存在的场合，也能不回到卡组加入手卡。
local s,id,o=GetID()
-- 创建并注册此卡的两个效果：e1为①效果的魔法卡发动效果，e2为②效果的墓地起动效果；两者都通过SetCountLimit(1,id)实现“这个卡名的①②的效果1回合只能有1次使用其中任意1个”的限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：丢弃1张手卡才能发动。从卡组把2只「科技属」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽回到卡组。自己场上有机械族「科技属」怪兽存在的场合，也能不回到卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将除外墓地中的这张卡自身作为②效果发动的代价（aux.bfgcost实现：检查可除外并除外自身）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
end
-- ①效果的代价函数：判定并执行“丢弃1张手卡”这一发动代价。若处于检查阶段（chk==0），先确认手牌中有无可丢弃的卡；确认后实际选择并丢弃1张手卡，丢弃原因同时包含代价和丢弃。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）确认：自己手牌中是否存在至少1张可以丢弃的卡（排除此卡自身），以满足“丢弃1张手卡才能发动”的代价条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌中选择1张可以丢弃的卡丢弃，丢弃原因标记为REASON_COST+REASON_DISCARD（作为代价丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果检索的筛选条件：卡组中的「科技属」怪兽，并且能够被加入手卡。
function s.filter(c)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动目标判定：检查卡组中是否存在至少2张卡名不同的、满足s.filter的「科技属」怪兽，以保证能检索2张同名卡最多1张；同时设置操作信息为从卡组将2张卡加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：用GetClassCount(Card.GetCode)统计卡组中符合筛选条件的卡的不同卡名数，要求大于1（即至少存在2张不同卡名的「科技属」怪兽），满足“同名卡最多1张”的检索条件。
	if chk==0 then return Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)>1 end
	-- 设置本连锁的操作信息：效果处理时会将2张卡从卡组加入手卡（目标位置为卡组，数量2），供其他卡的效果发动条件（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果处理：提示玩家选择要加入手卡的卡；从卡组筛选出所有符合条件的「科技属」怪兽，并让玩家选择2张卡名互不相同的怪兽；随后将选中的卡加入手卡并向对方展示确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出“请选择要加入手牌的卡”的提示消息，并将该提示写入选择缓存，以便后续选择框显示相应文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中取得所有满足s.filter的「科技属」怪兽，并通过SelectSubGroup让玩家选择2张，且用aux.dncheck保证所选2张卡名互不相同（同名卡最多1张）。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil):SelectSubGroup(tp,aux.dncheck,false,2,2)
	if g then
		-- 将选中的2张「科技属」怪兽以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的2张卡展示给对方玩家确认，以证明效果处理无误。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义s.cfilter：用于检测自己场上是否存在表侧表示的机械族「科技属」怪兽（作为②效果追加“加入手卡”选项的条件）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsSetCard(0x27)
end
-- 定义②效果可选对象的筛选条件：墓地中的「科技属」怪兽，且能够回到卡组；当chk为真（即自己场上有机械族「科技属」怪兽）时，也允许选择能够加入手卡的怪兽。
function s.rfilter(c,chk)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or chk and c:IsAbleToHand())
end
-- ②效果的发动目标判定：先检测自己场上是否存在机械族「科技属」怪兽，再检查墓地中是否有满足s.rfilter的对象；若存在，则让玩家选择1只对象，并设置操作信息为回卡组。
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测自己场上是否表侧表示存在机械族「科技属」怪兽，将结果作为是否能选择“加入手卡”分支的额外参数check。
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rfilter(chkc,check) end
	-- 发动合法性检查：确认自己墓地中存在至少1只满足s.rfilter（且根据check决定是否允许手卡分支）的「科技属」怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_GRAVE,0,1,nil,check) end
	-- 向玩家发出“请选择效果的对象”的提示消息，并写入选择缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只满足s.rfilter的「科技属」怪兽作为效果对象，并将该对象与当前连锁关联；同时把check作为额外参数传入过滤条件。
	local g=Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil,check)
	-- 设置操作信息：效果处理时将使对象怪兽回到卡组（CATEGORY_TODECK），目标为所选对象，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若对象与效果已失去联系则终止；若自己场上有机械族「科技属」怪兽且对象能加入手卡，则弹出选项让玩家选择“回到卡组”或“加入手卡”，选择加入手卡时执行加入手卡并展示，否则将对象洗回卡组。
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 重新检查处理时自己场上是否仍有机械族「科技属」怪兽，且对象怪兽当前能够加入手卡；以此决定是否提供“不回到卡组加入手卡”的选项。
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and tc:IsAbleToHand()
	-- 若满足上述条件，弹出两个选项供玩家选择；当Duel.SelectOption(tp,1190,1193)返回0时执行加入手卡分支，否则执行回到卡组分支。
	if check and Duel.SelectOption(tp,1190,1193)==0 then
		-- 把对象怪兽以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽，以进行确认。
		Duel.ConfirmCards(1-tp,tc)
	-- 将对象怪兽以效果原因（REASON_EFFECT）洗回持有者卡组（SEQ_DECKSHUFFLE表示弹回卡组并洗牌）。
	else Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
