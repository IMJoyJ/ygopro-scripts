--ラスティン・マンモス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，连接标记合计直到5为止从额外卡组把机械族连接怪兽除外才能发动。这张卡特殊召唤。
-- ②：以自己以及对方场上的卡各1张为对象才能发动（这张卡是和连接3以上的机械族连接怪兽连接状态的场合，这个效果在对方回合也能发动）。那些卡回到手卡。
local s,id,o=GetID()
-- 注册三个效果：①为手卡发动的起动效果，通过除外额外卡组的机械族连接怪兽作为代价把这张卡特殊召唤，1回合1次；②为取双方场上各1张卡为对象使其回到手卡的起动效果，1回合1次；③为②的复制版本，在连接状态下变为可在对方回合发动的诱发即时效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，连接标记合计直到5为止从额外卡组把机械族连接怪兽除外才能发动。这张卡特殊召唤。（这个卡名的①的效果1回合只能使用1次）
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
	-- ②：以自己以及对方场上的卡各1张为对象才能发动。那些卡回到手卡。（这个卡名的②的效果1回合只能使用1次）
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
-- 代价用过滤函数：筛选额外卡组中连接标记1以上、可以除外作为代价的机械族连接怪兽
function s.rfilter(c)
	return c:IsLinkAbove(1) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- 子组判定函数：所选卡的连接标记合计必须恰好等于5
function s.fselect(g)
	return g:GetSum(Card.GetLink)==5
end
-- 附加判定函数：所选卡的连接标记合计不得超过5，用于选择过程中限制继续增加选择
function s.gcheck(g)
	return g:GetSum(Card.GetLink)<=5
end
-- ①效果的代价：从额外卡组选出连接标记合计为5的机械族连接怪兽并作为代价正面表示除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己额外卡组检索满足代价条件（连接1以上的机械族连接怪兽且可除外）的卡
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_EXTRA,0,nil)
	-- 设置附加判定：选择过程中已选卡的连接标记合计不能超过5
	aux.GCheckAdditional=s.gcheck
	if chk==0 then
		local res=g:CheckSubGroup(s.fselect,1,g:GetCount(),tp)
		-- 清除附加判定函数，避免影响后续处理
		aux.GCheckAdditional=nil
		return res
	end
	-- 向玩家提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,s.fselect,false,1,g:GetCount(),tp)
	-- 选择完毕后清除附加判定函数
	aux.GCheckAdditional=nil
	-- 把选出的机械族连接怪兽以正面表示除外作为代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ①效果的目标确认：检查自己主要怪兽区有空位且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己主要怪兽区必须有可用空格，且这张卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣告本次连锁将进行1张卡（这张卡自身）的特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与此连锁关联，则将其在自己场上正面表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡在自己场上以正面表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选场上表侧表示的连接3以上的机械族连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLinkAbove(3) and c:IsType(TYPE_LINK)
end
-- 收集与双方场上连接3以上的机械族连接怪兽处于连接状态的所有卡
function s.getlg(tp)
	-- 检索双方场上表侧表示的连接3以上的机械族连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 逐一遍历这些连接3以上的机械族连接怪兽
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2
end
-- ②效果（起动版）的发动条件：这张卡未与连接3以上的机械族连接怪兽处于连接状态
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local lg2=s.getlg(tp)
	return not lg2 or not lg2:IsContains(e:GetHandler())
end
-- ②效果（即时版）的发动条件：这张卡与连接3以上的机械族连接怪兽处于连接状态，此时可在对方回合发动
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local lg2=s.getlg(tp)
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 对象过滤函数：场上可以回到手卡且能成为此效果对象的卡
function s.thfilter(c,e)
	return c:IsAbleToHand()
		and c:IsCanBeEffectTarget(e)
end
-- 子组判定函数：所选2张卡中自己与对方控制的卡各1张
function s.gcheck2(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==g:FilterCount(Card.IsControler,nil,1-tp)
end
-- ②效果的对象选择：从双方场上各选1张可回手卡的卡作为对象，并设置回到手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检索双方场上所有可回到手卡且能成为效果对象的卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck2,2,2,tp) end
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck2,false,2,2,tp)
	-- 把选出的2张卡设置为此连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：宣告本次连锁将把对象卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- ②效果的处理：取出仍与此连锁关联且在场上的对象卡，将它们回到持有者的手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与此连锁关联的对象卡中仍在场上的卡
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if sg:GetCount()>0 then
		-- 把那些卡以效果原因回到各自持有者的手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
