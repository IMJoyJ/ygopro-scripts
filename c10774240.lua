--粛声なる守護者ローガーディアン
-- 效果：
-- 「肃声之祈祷」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡仪式召唤的场合才能发动。从卡组把1只「肃声」怪兽或者战士族·龙族的仪式怪兽加入手卡。
-- ②：只要自己的场上或墓地有「肃声的祈祷者 理」存在，这张卡的攻击力上升2050。
-- ③：自己场上有「肃声的祈祷者 理」存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化效果：设定「肃声之祈祷」降临的仪式召唤限制（仅可用其仪式召唤），并注册①检索、③无效破坏、②攻击力上升三个效果，其中①③各有1回合1次的次数限制。
function s.initial_effect(c)
	-- 将「肃声之祈祷」（52472775）与「肃声的祈祷者 理」（25801745）登记为这张卡记载的卡名。
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
-- ①效果的发动条件：这张卡必须为仪式召唤成功（场合型触发）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 定义①效果的检索范围：选择「肃声」怪兽，或战士族·龙族的仪式怪兽，且必须是怪兽卡并能加入手卡。
function s.thfilter(c)
	return (c:IsSetCard(0x1a6) or (c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL))) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动时的目标处理：先检查卡组是否存在符合条件的检索对象，再预设本次处理将把卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：卡组中是否至少有1张满足s.thfilter的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理预计将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：让玩家从卡组选择1只符合条件的怪兽加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张符合s.thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义用于检测「肃声的祈祷者 理」的过滤器：表侧表示且卡号为25801745（场上或墓地均可）。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(25801745)
end
-- ③效果的发动条件：对方发动的效果进入连锁、自己场上有表侧表示的「肃声的祈祷者 理」、该连锁可以被无效，且此卡未被战斗破坏。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定：发动方为对方、当前连锁可以被无效、此卡未被战斗破坏。
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		-- 判定：自己场上存在表侧表示的「肃声的祈祷者 理」。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ③效果的目标及操作信息设置：不取对象；将对方发动效果的那张卡（eg）设为无效对象；若它可被破坏且仍与效果关联，则同时设为破坏对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将eg（对方发动效果的那张卡）作为无效的对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将eg作为破坏的对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：无效对方发动的那个效果，若其发动卡仍与效果关联，则将其破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行无效操作；无效成功且发动效果的卡仍与效果关联时，进入破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将对方发动效果的那张卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果的条件：只要自己的场上或墓地存在「肃声的祈祷者 理」，攻击力上升2050。
function s.atkcon(e)
	-- 检查自己场上或墓地是否存在表侧表示的「肃声的祈祷者 理」。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
end
