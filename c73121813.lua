--天威龍－ムーラ・アーダラ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合，若自己的墓地·除外状态的幻龙族怪兽2只以上存在则能发动。从卡组把1张场地魔法卡加入手卡。
-- ②：只要场上有效果怪兽以外的表侧表示怪兽存在，这张卡得到以下效果。
-- ●这张卡不会被对方的效果破坏。
-- ●对方不能把这张卡作为效果的对象。
-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、同调召唤成功时检索场地魔法的效果，以及场上有非效果怪兽存在时获得抗性和追加攻击的效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，若自己的墓地·除外状态的幻龙族怪兽2只以上存在则能发动。从卡组把1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ●这张卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.intcon)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ●对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.intcon)
	-- 设置不能成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetCondition(s.intcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 检索效果的发动条件：这张卡同调召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索卡片的过滤条件：卡组中的场地魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在场地魔法，且自己墓地或除外状态的幻龙族怪兽是否有2只以上，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查卡组中是否存在可以加入手牌的场地魔法卡
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			-- 检查自己的墓地或除外状态是否存在2只以上的幻龙族怪兽
			and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsRace),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil,RACE_WYRM)
	end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1张场地魔法卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片通过效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 获得抗性与追加攻击效果的适用条件：场上有效果怪兽以外的表侧表示怪兽存在
function s.intcon(e)
	-- 检查双方场上是否存在表侧表示的非效果怪兽
	return Duel.IsExistingMatchingCard(aux.AND(aux.NOT(Card.IsType),Card.IsFaceup),e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_EFFECT)
end
