--粛声なる守護者ローガーディアン
-- 效果：
-- 「肃声之祈祷」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡仪式召唤的场合才能发动。从卡组把1只「肃声」怪兽或者战士族·龙族的仪式怪兽加入手卡。
-- ②：只要自己的场上或墓地有「肃声的祈祷者 理」存在，这张卡的攻击力上升2050。
-- ③：自己场上有「肃声的祈祷者 理」存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码，标记该卡效果中提及了「肃声之祈祷」和「肃声的祈祷者 理」
	aux.AddCodeList(c,52472775,25801745)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合才能发动。从卡组把1只「肃声」怪兽或者战士族·龙族的仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ③：自己场上有「肃声的祈祷者 理」存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ②：只要自己的场上或墓地有「肃声的祈祷者 理」存在，这张卡的攻击力上升2050。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(2050)
	c:RegisterEffect(e3)
end
-- 判断是否为仪式召唤成功触发的效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检索过滤函数，筛选「肃声」怪兽或战士族·龙族的仪式怪兽
function s.thfilter(c)
	return (c:IsSetCard(0x1a6) or (c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL))) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果发动时的处理目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即卡组中存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择从卡组加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的1张卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断场上或墓地是否存在「肃声的祈祷者 理」
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(25801745)
end
-- 判断是否满足无效发动的条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动方是否为对方，且该卡未在战斗中被破坏，且该连锁可被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		-- 判断自己场上或墓地是否存在「肃声的祈祷者 理」
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置无效发动时的处理目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息，表示将破坏发动的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效发动并破坏的处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效，并判断发动的卡片是否可破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断攻击力提升效果是否满足条件
function s.atkcon(e)
	-- 检查场上或墓地是否存在「肃声的祈祷者 理」
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
end
