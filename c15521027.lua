--D・スマホン
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只「变形斗士」怪兽除外的场合可以特殊召唤。
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中把1张「变形斗士」卡加入手卡，剩余回到卡组。
-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认，用喜欢的顺序回到卡组上面或下面。
function c15521027.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只「变形斗士」怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15521027,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15521027.spcon)
	e1:SetTarget(c15521027.sptg)
	e1:SetOperation(c15521027.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡得到表示形式的以下效果。●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中把1张「变形斗士」卡加入手卡，剩余回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15521027,1))  --"确认卡组"
	e2:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c15521027.cona)
	e2:SetTarget(c15521027.tga)
	e2:SetOperation(c15521027.opa)
	c:RegisterEffect(e2)
	-- ①：这张卡得到表示形式的以下效果。●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认，用喜欢的顺序回到卡组上面或下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15521027,2))  --"确认卡组顺序"
	e3:SetCategory(CATEGORY_DICE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c15521027.cond)
	e3:SetTarget(c15521027.tgd)
	e3:SetOperation(c15521027.opd)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断墓地中的卡是否为「变形斗士」怪兽，且可以作为特殊召唤的COST被除外。
function c15521027.spfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定：自己场上有空余的主要怪兽区，且自己墓地存在1只满足spfilter的「变形斗士」怪兽。
function c15521027.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足spfilter过滤条件的「变形斗士」怪兽。
		and Duel.IsExistingMatchingCard(c15521027.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的选择处理：从墓地的候选卡中选择1只「变形斗士」怪兽作为除外的COST，并存入效果标签；若选择成功则允许特殊召唤。
function c15521027.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可作为COST除外的「变形斗士」怪兽集合。
	local g=Duel.GetMatchingGroup(c15521027.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家正在选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的代价处理：将之前选择的那只「变形斗士」怪兽从墓地除外。
function c15521027.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡从墓地除外（表侧表示），除外原因视为特殊召唤手续。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- e2效果的发动条件：这张卡处于攻击表示。
function c15521027.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 攻击表示效果的发动条件与连锁信息设置：确认卡组有卡可翻；设置掷骰子操作信息。
function c15521027.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己卡组至少有1张卡才能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置本次连锁的操作信息：包含掷骰子分类（CATEGORY_DICE），用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 过滤函数：判断翻开的卡是否为「变形斗士」卡且可以被加入手卡。
function c15521027.filter(c)
	return c:IsSetCard(0x26) and c:IsAbleToHand()
end
-- 攻击表示效果的处理：掷1次骰子，翻开卡组顶相应数量卡；选1张「变形斗士」卡加入手卡，其余洗回卡组；然后洗切卡组。
function c15521027.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若卡组无卡则终止效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 掷1次骰子，得到点数dc。
	local dc=Duel.TossDice(tp,1)
	-- 翻开自己卡组最上方dc张卡（向双方确认）。
	Duel.ConfirmDecktop(tp,dc)
	-- 获取卡组最上方dc张卡的集合。
	local dg=Duel.GetDecktopGroup(tp,dc)
	local g=dg:Filter(c15521027.filter,nil)
	if g:GetCount()>0 then
		-- 提示玩家正在选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入其持有者手卡，原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
	-- 洗切自己卡组，将翻开的剩余卡返回卡组。
	Duel.ShuffleDeck(tp)
end
-- e3效果的发动条件：这张卡处于守备表示。
function c15521027.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 守备表示效果的发动条件与连锁信息设置：确认卡组有卡可确认；设置掷骰子操作信息。
function c15521027.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己卡组至少有1张卡才能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置本次连锁的操作信息：包含掷骰子分类，用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 守备表示效果的处理：掷1次骰子，确认卡组顶相应数量卡；玩家选择按喜欢的顺序放回卡组顶或卡组底。
function c15521027.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若卡组无卡则终止效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 掷1次骰子，得到点数dc。
	local dc=Duel.TossDice(tp,1)
	-- 获取卡组最上方dc张卡的集合。
	local g=Duel.GetDecktopGroup(tp,dc)
	local ct=g:GetCount()
	-- 由自己确认这些卡片（不向对方展示）。
	Duel.ConfirmCards(tp,g)
	-- 弹出选项，让玩家选择将确认的卡放回卡组上面还是下面；op=0表示上，1表示下。
	local op=Duel.SelectOption(tp,aux.Stringid(15521027,3),aux.Stringid(15521027,4))  --"放回卡组上面/放回卡组下面"
	-- 让玩家对卡组顶ct张卡进行排序，决定放回卡组（上面或下面）时的顺序。
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 获取当前卡组最上方1张卡（用于移动到卡组底）。
		local tg=Duel.GetDecktopGroup(tp,1)
		-- 将该卡移动到卡组最底部；循环处理将所有排序后的卡按顺序放回底部。
		Duel.MoveSequence(tg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
