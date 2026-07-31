--ラスティン・マンモス
-- 效果：
-- 这张卡在手卡存在的场合：可以从自己的额外卡组把连接标记合计为5的机械族连接怪兽除外；这张卡特殊召唤。
-- 可以以自己·对方场上的卡各1张为对象；那些卡回到手卡。这张卡在连接3以上的机械族连接怪兽所连接区存在的场合，这个效果在对方回合也能发动。
-- 「锈蚀猛犸」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建两个效果，第一个为手牌特殊召唤效果，第二个为场上的卡回到手牌效果
function s.initial_effect(c)
	-- 这张卡在手卡存在的场合：可以从自己的额外卡组把连接标记合计为5的机械族连接怪兽除外；这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 可以以自己·对方场上的卡各1张为对象；那些卡回到手卡。这张卡在连接3以上的机械族连接怪兽所连接区存在的场合，这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.thcon2)
	c:RegisterEffect(e3)
end
-- 过滤满足连接标记大于等于1、种族为机械、类型为连接且能作为除外费用的额外卡组怪兽
function s.rfilter(c)
	return c:IsLinkAbove(1) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- 判断卡片组中是否存在连接标记总和为5的子集
function s.fselect(g)
	return g:GetSum(Card.GetLink)==5
end
-- 用于检查卡片组中所有卡片的连接标记总和是否小于等于5
function s.gcheck(g)
	return g:GetSum(Card.GetLink)<=5
end
-- 处理特殊召唤效果的费用，从额外卡组选择满足条件的连接怪兽除外作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的额外卡组怪兽组
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_EXTRA,0,nil)
	-- 设置额外检查函数用于筛选符合条件的子集
	aux.GCheckAdditional=s.gcheck
	if chk==0 then
		local res=g:CheckSubGroup(s.fselect,1,g:GetCount(),tp)
		-- 清除额外检查函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,s.fselect,false,1,g:GetCount(),tp)
	-- 清除额外检查函数
	aux.GCheckAdditional=nil
	-- 将选中的卡片以除外形式移除
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤效果的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件（场上是否有空位且该卡可特殊召唤）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足正面表示、种族为机械、连接标记大于等于3、类型为连接的场上怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLinkAbove(3) and c:IsType(TYPE_LINK)
end
-- 获取所有满足条件的场上怪兽，并合并其连接区的怪兽组
function s.getlg(tp)
	-- 获取所有满足条件的场上怪兽组
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历满足条件的场上怪兽组中的每张卡
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2
end
-- 判断该卡是否在连接3以上的机械族连接怪兽所连接区（用于触发效果）
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local lg2=s.getlg(tp)
	return not lg2 or not lg2:IsContains(e:GetHandler())
end
-- 判断该卡是否在连接3以上的机械族连接怪兽所连接区（用于对方回合发动）
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local lg2=s.getlg(tp)
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 过滤满足能回到手牌且可成为效果对象的场上卡
function s.thfilter(c,e)
	return c:IsAbleToHand()
		and c:IsCanBeEffectTarget(e)
end
-- 检查卡片组中是否包含自己和对方各一张卡
function s.gcheck2(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==g:FilterCount(Card.IsControler,nil,1-tp)
end
-- 设置回手牌效果的目标，选择符合条件的两张场上的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取所有满足条件的场上卡组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck2,2,2,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck2,false,2,2,tp)
	-- 设置当前处理连锁的对象为选中的卡
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示将这些卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 执行回手牌效果的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象卡组，并筛选在场上的卡
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if sg:GetCount()>0 then
		-- 将符合条件的卡送回手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
