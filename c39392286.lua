--ハーピィ・パフューマー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。自己场上有5星以上的「鹰身」怪兽存在的状态把这个效果发动的场合，这个效果加入手卡的数量可以变成2张（同名卡最多1张）。
function c39392286.initial_effect(c)
	-- 记录本卡效果文本中记载了「鹰身女郎三姐妹」（12206212）这一卡名，使后续可用aux.IsCodeListed判断卡组中哪些卡有该记述。
	aux.AddCodeList(c,12206212)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。自己场上有5星以上的「鹰身」怪兽存在的状态把这个效果发动的场合，这个效果加入手卡的数量可以变成2张（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39392286,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,39392286)
	e1:SetTarget(c39392286.thtg)
	e1:SetOperation(c39392286.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 给本卡注册①效果：只要在场上或墓地存在，卡名当作「鹰身女郎」（76812113）使用。
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 定义检索用过滤函数：筛选出效果文本中记载了「鹰身女郎三姐妹」、属于魔法·陷阱卡且能够加入手卡的卡。
function c39392286.thfilter(c)
	-- 判断该卡是否满足：记载了「鹰身女郎三姐妹」卡名、是魔法·陷阱卡、且可以被加入手卡。
	return aux.IsCodeListed(c,12206212) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义辅助过滤函数：用于判断场上是否存在满足条件的「鹰身」怪兽，作为是否检索2张的依据。
function c39392286.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- 发动条件的判定与操作信息设定：先确认卡组中有可检索的卡；再检查自己场上是否有5星以上的「鹰身」怪兽，有则用标签记录为1；最后向系统登记本次为从卡组将1张卡加入手卡的效果。
function c39392286.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认卡组中存在至少1张满足检索条件的魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39392286.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetLabel(0)
	-- 若自己场上有表侧表示、5星以上的「鹰身」怪兽，则将效果的标签设为1，用于在处理阶段决定检索数量为2。
	if Duel.IsExistingMatchingCard(c39392286.filter,tp,LOCATION_MZONE,0,1,nil) then e:SetLabel(1) end
	-- 向系统登记操作信息：本次效果会从卡组把卡加入手卡，预计数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组中筛选出所有满足条件的魔法·陷阱卡，根据标签决定检索1张或2张，选择时要求卡名互不相同，加入手卡并向对方确认。
function c39392286.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有满足检索条件的魔法·陷阱卡，暂存为卡片组g。
	local g=Duel.GetMatchingGroup(c39392286.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<=0 then return end
	local ct=1
	if e:GetLabel()==1 then ct=2 end
	-- 给当前玩家显示'请选择要加入手牌的卡'的选择提示，用于后续选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从g中选择1~ct张卡，且选出的卡卡名互不相同；如果ct为2，则选择2张不同卡名的卡。
	local sg1=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 将选中的卡以效果原因加入其持有者的手卡。
	Duel.SendtoHand(sg1,nil,REASON_EFFECT)
	-- 向对方玩家展示本次加入手卡的卡，以确认检索结果。
	Duel.ConfirmCards(1-tp,sg1)
end
