--粛声なる守護者ローガーディアン
-- 效果：
-- 「肃声之祈祷」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡仪式召唤的场合才能发动。从卡组把1只「肃声」怪兽或者战士族·龙族的仪式怪兽加入手卡。
-- ②：只要自己的场上或墓地有「肃声的祈祷者 理」存在，这张卡的攻击力上升2050。
-- ③：自己场上有「肃声的祈祷者 理」存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册相关卡号并启用特殊召唤限制，创建三个效果
function s.initial_effect(c)
	-- 记录该卡与「肃声之祈祷」和「肃声的祈祷者 理」的关联
	aux.AddCodeList(c,52472775,25801745)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合才能发动。从卡组把1只「肃声」怪兽或者战士族·龙族的仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
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
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
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
-- 效果条件：确认此卡是否为仪式召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检索过滤函数：筛选「肃声」怪兽或战士族·龙族的仪式怪兽
function s.thfilter(c)
	return (c:IsSetCard(0x1a6) or (c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL))) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标：确认卡组是否存在满足条件的怪兽并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示选择并执行将符合条件的怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断场上的「肃声的祈祷者 理」是否存在于场上或墓地
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(25801745)
end
-- 效果条件：确认对方发动效果且己方场上有「肃声的祈祷者 理」
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方发动效果且此卡未在战斗阶段被破坏
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		-- 确认己方场上有「肃声的祈祷者 理」
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果目标：设置无效发动和破坏目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏对应卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果条件：判断己方场上有或墓地有「肃声的祈祷者 理」
function s.atkcon(e)
	-- 检查己方场上或墓地是否存在「肃声的祈祷者 理」
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
end
