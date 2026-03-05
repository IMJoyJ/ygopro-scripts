--U.A.スタジアム
-- 效果：
-- ①：自己场上有「超级运动员」怪兽召唤的场合才能发动。从卡组把1只「超级运动员」怪兽加入手卡。
-- ②：1回合1次，自己场上有「超级运动员」怪兽特殊召唤的场合发动。自己场上的怪兽的攻击力上升500。
function c19814508.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己场上有「超级运动员」怪兽召唤的场合才能发动。从卡组把1只「超级运动员」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19814508,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c19814508.target)
	e2:SetOperation(c19814508.operation)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：1回合1次，自己场上有「超级运动员」怪兽特殊召唤的场合发动。自己场上的怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19814508,1))  --"攻守变化"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c19814508.atkcon)
	e3:SetOperation(c19814508.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「超级运动员」怪兽（怪兽卡且可加入手牌）
function c19814508.filter(c)
	return c:IsSetCard(0xb2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否满足发动条件：召唤的怪兽为「超级运动员」且为玩家控制
function c19814508.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsSetCard(0xb2) and tc:IsControler(tp)
		-- 判断卡组中是否存在满足条件的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c19814508.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：提示玩家选择卡组中的「超级运动员」怪兽并加入手牌
function c19814508.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「超级运动员」怪兽
	local g=Duel.SelectMatchingCard(tp,c19814508.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于筛选玩家控制且表侧表示的「超级运动员」怪兽
function c19814508.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and c:IsControler(tp)
end
-- 判断是否有满足条件的「超级运动员」怪兽被特殊召唤
function c19814508.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19814508.cfilter,1,nil,tp)
end
-- 效果处理函数：使自己场上的所有表侧表示怪兽攻击力上升500
function c19814508.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每个怪兽添加攻击力增加500的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(500)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
