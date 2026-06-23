--D・スマホン
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只「变形斗士」怪兽除外的场合可以特殊召唤。
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中把1张「变形斗士」卡加入手卡，剩余回到卡组。
-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认，用喜欢的顺序回到卡组上面或下面。
function c15521027.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只「变形斗士」怪兽除外的场合可以特殊召唤
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
	-- 1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中把1张「变形斗士」卡加入手卡，剩余回到卡组。
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
	-- 1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认，用喜欢的顺序回到卡组上面或下面。
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
-- 过滤函数，用于判断墓地中的「变形斗士」怪兽是否可以除外作为特殊召唤的代价
function c15521027.spfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件：场上存在空位且墓地存在「变形斗士」怪兽
function c15521027.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在「变形斗士」怪兽
		and Duel.IsExistingMatchingCard(c15521027.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 设置特殊召唤时选择除外的卡片
function c15521027.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取墓地中的「变形斗士」怪兽
	local g=Duel.GetMatchingGroup(c15521027.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选择的卡除外
function c15521027.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 判断此卡是否处于攻击表示
function c15521027.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 设置攻击表示效果的发动条件
function c15521027.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否为空
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置发动时的骰子效果信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 过滤函数，用于判断卡组顶部的卡是否为「变形斗士」卡
function c15521027.filter(c)
	return c:IsSetCard(0x26) and c:IsAbleToHand()
end
-- 执行攻击表示效果，投掷骰子并处理卡组顶部的卡
function c15521027.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组是否为空
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 投掷一次骰子
	local dc=Duel.TossDice(tp,1)
	-- 确认卡组顶部的骰子数目的卡
	Duel.ConfirmDecktop(tp,dc)
	-- 获取卡组顶部的骰子数目的卡
	local dg=Duel.GetDecktopGroup(tp,dc)
	local g=dg:Filter(c15521027.filter,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
	-- 洗切卡组
	Duel.ShuffleDeck(tp)
end
-- 判断此卡是否处于守备表示
function c15521027.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 设置守备表示效果的发动条件
function c15521027.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否为空
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置发动时的骰子效果信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 执行守备表示效果，投掷骰子并处理卡组顶部的卡
function c15521027.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组是否为空
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 投掷一次骰子
	local dc=Duel.TossDice(tp,1)
	-- 获取卡组顶部的骰子数目的卡
	local g=Duel.GetDecktopGroup(tp,dc)
	local ct=g:GetCount()
	-- 确认卡组顶部的卡
	Duel.ConfirmCards(tp,g)
	-- 提示玩家选择将卡放回卡组上面或下面
	local op=Duel.SelectOption(tp,aux.Stringid(15521027,3),aux.Stringid(15521027,4))  --"放回卡组上面/放回卡组下面"
	-- 对卡组顶部的卡进行排序
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 获取卡组顶部的卡
		local tg=Duel.GetDecktopGroup(tp,1)
		-- 将卡移动到卡组底部
		Duel.MoveSequence(tg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
