--Rustin Mammoth
-- 效果：
-- 这张卡在手卡存在的场合：可以从自己的额外卡组把连接标记合计为5的机械族连接怪兽除外；这张卡特殊召唤。
-- 可以以自己·对方场上的卡各1张为对象；那些卡回到手卡。这张卡在连接3以上的机械族连接怪兽所连接区存在的场合，这个效果在对方回合也能发动。
-- 「锈蚀猛犸」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果：注册①效果（手牌起动特召）以及②效果（非所连接区时己方回合起动回收场上卡片）、③效果（所连接区时双方回合二速起动回收场上卡片）。
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
-- 过滤条件：可以作为发动代价除外的额外卡组机械族连接怪兽。
function s.rfilter(c)
	return c:IsLinkAbove(1) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- 判断所选取的额外怪兽的连接标记（Link数）总和是否等于5。
function s.fselect(g)
	return g:GetSum(Card.GetLink)==5
end
-- 在玩家选择额外怪兽时，限制所选怪兽的连接标记总和不能超过5。
function s.gcheck(g)
	return g:GetSum(Card.GetLink)<=5
end
-- 特召效果的发动代价：从额外卡组把连接标记合计为5的机械族连接怪兽正面除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方额外卡组中所有符合除外条件的机械族连接怪兽。
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_EXTRA,0,nil)
	-- 设置玩家选取额外怪兽时的临时限制函数，限制选择的连接标记总和在5以内。
	aux.GCheckAdditional=s.gcheck
	if chk==0 then
		local res=g:CheckSubGroup(s.fselect,1,g:GetCount(),tp)
		-- 清除设置的选择额外怪兽的临时限制函数。
		aux.GCheckAdditional=nil
		return res
	end
	-- 提示玩家选择作为发动代价需要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,s.fselect,false,1,g:GetCount(),tp)
	-- 清除设置的选择额外怪兽的临时限制函数。
	aux.GCheckAdditional=nil
	-- 将选定的额外怪兽正面向上除外作为发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 特召效果的发动目标：检查自己场上是否有空位以及此卡是否可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，确认己方主要怪兽区域有空位，且此卡可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：效果处理时会将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特召效果的处理：将这张卡从手牌特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示、连接3以上的机械族连接怪兽。
function s.ecfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLinkAbove(3) and c:IsType(TYPE_LINK)
end
-- 获取场上所有符合条件的连接怪兽所连接的怪兽区域中的卡片集合。
function s.getlg(tp)
	-- 获取场上所有表侧表示且连接3以上的机械族连接怪兽。
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历所有符合条件的连接怪兽，将其指向的怪兽区域卡片组进行合并。
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2
end
-- 回收效果在己方回合的发动条件：这张卡不在任何连接3以上的机械族连接怪兽所指向的区域。
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local lg2=s.getlg(tp)
	return not lg2 or not lg2:IsContains(e:GetHandler())
end
-- 回收效果在双方回合的发动条件：这张卡在连接3以上的机械族连接怪兽所指向的区域存在。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local lg2=s.getlg(tp)
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 过滤条件：可以作为效果对象且可以送回手牌的场上卡片。
function s.thfilter(c,e)
	return c:IsAbleToHand()
		and c:IsCanBeEffectTarget(e)
end
-- 判断所选取的2张卡片中是否属于自己和对方场上卡片各1张。
function s.gcheck2(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==g:FilterCount(Card.IsControler,nil,1-tp)
end
-- 回收效果的发动目标：选择自己·对方场上的各1张卡作为效果对象，并设置返回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有符合条件的自己·对方卡片。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck2,2,2,tp) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck2,false,2,2,tp)
	-- 将选中的2张卡片登记为效果的对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：效果处理时将选中的卡片送回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 回收效果的处理：将选中的场上对象卡片送回持有者的手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时仍与效果相关且仍存在于场上的对象卡片。
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if sg:GetCount()>0 then
		-- 将选定的对象卡片送回持有者的手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
