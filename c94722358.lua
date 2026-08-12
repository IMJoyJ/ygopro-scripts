--M∀LICE＜C＞MTP－07
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
-- ①：从卡组把1只「码丽丝」怪兽加入手卡。自己场上有「码丽丝」连接怪兽存在的场合，可以再把场上1张卡除外。
local s,id,o=GetID()
-- 初始化效果：注册卡片发动效果，以及在盖放回合发动的特殊规则效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「码丽丝」怪兽加入手卡。自己场上有「码丽丝」连接怪兽存在的场合，可以再把场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"适用「码丽丝<代码>MTP-07」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中「码丽丝」怪兽且能加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「码丽丝」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：自己场上表侧表示的「码丽丝」连接怪兽
function s.filter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- ①效果的处理：检索「码丽丝」怪兽，若满足条件则可选择除外场上1张卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「码丽丝」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否存在「码丽丝」连接怪兽
		if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
			-- 检查场上是否存在除这张卡以外可以被除外的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
			-- 询问玩家是否选择适用除外效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡除外？"
			-- 中断当前效果处理，使后续除外处理不与检索同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 玩家选择场上1张可以被除外的卡（排除此卡自身）
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
			-- 闪烁显示被选择除外的卡
			Duel.HintSelection(rg)
			-- 将选中的卡因效果表侧表示除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己场上表侧表示且能作为Cost除外的「码丽丝」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1bf) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
-- 盖放回合发动此卡时的Cost处理
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为Cost除外的「码丽丝」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡作为Cost
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己场上1只表侧表示的「码丽丝」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
