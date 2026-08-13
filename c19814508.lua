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
	-- ①：自己场上有「超级运动员」怪兽召唤的场合才能发动。从卡组把1只「超级运动员」怪兽加入手卡。
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
	-- ②：1回合1次，自己场上有「超级运动员」怪兽特殊召唤的场合发动。自己场上的怪兽的攻击力上升500。
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
-- 定义检索筛选条件：判断卡是否为「超级运动员」怪兽且可以加入手卡，用于从卡组检索。
function c19814508.filter(c)
	return c:IsSetCard(0xb2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动条件判定：检查这次召唤成功的怪兽是否为「超级运动员」且为己方控制，并存在可检索的「超级运动员」怪兽。
function c19814508.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsSetCard(0xb2) and tc:IsControler(tp)
		-- 检查卡组中是否存在至少1张满足filter过滤条件的「超级运动员」怪兽。
		and Duel.IsExistingMatchingCard(c19814508.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：将执行从卡组把1张卡加入手卡的效果，目标为tp的卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只「超级运动员」怪兽加入手卡，并向对方玩家展示。
function c19814508.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片提示，要求己方玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从卡组中选择1只满足filter条件的「超级运动员」怪兽。
	local g=Duel.SelectMatchingCard(tp,c19814508.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义特殊召唤成功怪兽的筛选条件：表侧表示、持有「超级运动员」字段且为己方控制。
function c19814508.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and c:IsControler(tp)
end
-- ②效果的发动条件：这次特殊召唤成功的怪兽中存在满足cfilter条件的「超级运动员」怪兽。
function c19814508.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19814508.cfilter,1,nil,tp)
end
-- ②效果处理：使己方场上所有表侧表示怪兽的攻击力上升500。
function c19814508.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- ②：自己场上的怪兽的攻击力上升500。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(500)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
