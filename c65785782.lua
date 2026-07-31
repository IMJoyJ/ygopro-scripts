--呼応する伝説の都
local s,id,o=GetID()
-- 初始化卡片效果：注册①卡片发动及检索/无效效果、②墓地除外提升水属性怪兽攻守效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「海」及「传说之都 亚特兰蒂斯」
	aux.AddCodeList(c,38391684,22702055)
	-- ①：作为这张卡发动时的效果处理，从卡组把1只记有「海」卡名的怪兽加入手卡。自己场上有「海」存在，且对方场上有效果怪兽存在的场合，可以再选对方场上1只效果怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「海」存在的场合，把墓地的这张卡除外才能发动。自己场上的水属性怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- ②效果发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 卡组检索过滤条件：记有「海」卡名的怪兽且可加入手牌
function s.thfilter(c)
	-- 检查卡片是否记有「海」卡名、为怪兽卡且可加入手牌
	return aux.IsCodeListed(c,38391684) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动准备：设置从卡组检索卡片的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在记有「海」卡名的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 场上卡片过滤条件：表侧表示的「海」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(38391684)
end
-- ①效果处理：从卡组把1只记有「海」卡名的怪兽加入手卡，满足条件时可再选择对方场上1只效果怪兽使其效果无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只记有「海」卡名的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
			-- 检查自己场上是否存在表侧表示的「海」
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 检查对方场上是否存在可无效的效果怪兽
			and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否选择无效对方1只怪兽的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local c=e:GetHandler()
			-- 连接效果块（分隔检索加手与无效效果的操作）
			Duel.BreakEffect()
			-- 提示玩家选择要无效的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			-- 选择对方场上1只表侧表示的效果怪兽
			local ng=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 高亮显示选中的目标怪兽
			Duel.HintSelection(ng)
			local tc=ng:GetFirst()
			-- 使目标怪兽当前已发动的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使其效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使其效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 场地条件过滤条件：表侧表示的「传说之都 亚特兰蒂斯」
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(22702055)
end
-- ②效果发动条件检查：场上是否存在「传说之都 亚特兰蒂斯」或生效的环境为「海」
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的「传说之都 亚特兰蒂斯」或当前环境卡号为「海」
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- 攻守提升过滤条件：表侧表示的水属性怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ②效果发动准备：检查自己场上是否存在表侧表示的水属性怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否存在表侧表示的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果处理：自己场上的水属性怪兽的攻击力·守备力上升500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的水属性怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历所有选中的水属性怪兽
	for tc in aux.Next(g) do
		-- 攻击力·守备力上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
