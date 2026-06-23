--ハーピィ・パフューマー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。自己场上有5星以上的「鹰身」怪兽存在的状态把这个效果发动的场合，这个效果加入手卡的数量可以变成2张（同名卡最多1张）。
function c39392286.initial_effect(c)
	-- 记录该卡具有「鹰身女郎」的卡名记述
	aux.AddCodeList(c,12206212)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。自己场上有5星以上的「鹰身」怪兽存在的状态把这个效果发动的场合，这个效果加入手卡的数量可以变成2张（同名卡最多1张）。
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
	-- 使该卡在场上或墓地时视为「鹰身女郎」使用
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 过滤函数，用于筛选卡组中具有「鹰身女郎」卡名记述的魔法或陷阱卡
function c39392286.thfilter(c)
	-- 检测卡片是否具有「鹰身女郎」的卡名记述且为魔法或陷阱卡且可加入手牌
	return aux.IsCodeListed(c,12206212) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤函数，用于筛选场上存在的5星以上「鹰身」怪兽
function c39392286.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- 效果发动时的处理函数，判断是否满足额外条件并设置标签
function c39392286.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39392286.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetLabel(0)
	-- 若场上存在5星以上的「鹰身」怪兽，则设置标签为1
	if Duel.IsExistingMatchingCard(c39392286.filter,tp,LOCATION_MZONE,0,1,nil) then e:SetLabel(1) end
	-- 设置连锁操作信息，表示将从卡组检索1张魔法或陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c39392286.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的魔法或陷阱卡
	local g=Duel.GetMatchingGroup(c39392286.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<=0 then return end
	local ct=1
	if e:GetLabel()==1 then ct=2 end
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的卡中选择不超过指定数量且卡名不同的卡组
	local sg1=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 将选中的卡送入手牌
	Duel.SendtoHand(sg1,nil,REASON_EFFECT)
	-- 确认对方查看所选的卡
	Duel.ConfirmCards(1-tp,sg1)
end
