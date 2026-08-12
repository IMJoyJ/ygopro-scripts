--魔導騎士ギルティア－ソウル・スピア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤成功时才能发动。选持有这张卡的攻击力以上的攻击力的对方场上1只怪兽除外。
-- ③：丢弃1张手卡才能发动。从卡组把以下怪兽之内1只加入手卡。
-- ●龙族·暗属性·7星怪兽
-- ●机械族·暗属性·6星怪兽
-- ●战士族·水属性·5星怪兽
function c77406972.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77406972,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c77406972.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时才能发动。选持有这张卡的攻击力以上的攻击力的对方场上1只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77406972,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c77406972.rmtg)
	e2:SetOperation(c77406972.rmop)
	c:RegisterEffect(e2)
	-- ③：丢弃1张手卡才能发动。从卡组把以下怪兽之内1只加入手卡。●龙族·暗属性·7星怪兽●机械族·暗属性·6星怪兽●战士族·水属性·5星怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77406972,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,77406972)
	e3:SetCost(c77406972.thcost)
	e3:SetTarget(c77406972.thtg)
	e3:SetOperation(c77406972.thop)
	c:RegisterEffect(e3)
end
-- 不用解放作召唤的条件函数
function c77406972.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	-- 检查是否不需要解放、怪兽等级是否在5星以上，以及自己场上是否有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在怪兽（数量为0）
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤对方场上表侧表示且攻击力在指定数值以上的可除外怪兽
function c77406972.rmfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk) and c:IsAbleToRemove()
end
-- 召唤成功时除外效果的靶向/发动检测函数
function c77406972.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检测：对方场上是否存在持有这张卡攻击力以上的攻击力的表侧表示可除外怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77406972.rmfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 获取对方场上所有满足除外条件的怪兽组
	local g=Duel.GetMatchingGroup(c77406972.rmfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	-- 设置操作信息：除外对方场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 召唤成功时除外效果的处理函数
function c77406972.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择对方场上1只持有这张卡攻击力以上的攻击力的怪兽
	local g=Duel.SelectMatchingCard(tp,c77406972.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
	if g:GetCount()>0 then
		-- 选中卡片的视觉提示效果
		Duel.HintSelection(g)
		-- 将选中的怪兽表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 检索效果的代价（Cost）处理函数
function c77406972.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择1张可以丢弃的手牌
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌作为代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中符合条件的怪兽（龙族·暗属性·7星、机械族·暗属性·6星、战士族·水属性·5星）
function c77406972.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
		and ((c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(7) and c:IsRace(RACE_DRAGON))
			or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(6) and c:IsRace(RACE_MACHINE))
			or (c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(5) and c:IsRace(RACE_WARRIOR)))
end
-- 检索效果的发动检测与效果分类设置函数
function c77406972.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77406972.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function c77406972.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c77406972.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
