--ワーム・プリンス
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，可以从自己卡组把1只名字带有「异虫」的爬虫类族怪兽加入手卡。自己场上没有这张卡以外的名字带有「异虫」的爬虫类族怪兽存在的场合，结束阶段时这张卡破坏。
function c54860010.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，可以从自己卡组把1只名字带有「异虫」的爬虫类族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54860010,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(c54860010.thtg)
	e1:SetOperation(c54860010.thop)
	c:RegisterEffect(e1)
	-- 自己场上没有这张卡以外的名字带有「异虫」的爬虫类族怪兽存在的场合，结束阶段时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54860010,1))  --"自坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c54860010.descon)
	e2:SetTarget(c54860010.destg)
	e2:SetOperation(c54860010.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中名字带有「异虫」的爬虫类族怪兽且能加入手卡
function c54860010.filter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 效果1（检索）的靶向/发动检测函数
function c54860010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54860010.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1（检索）的效果处理函数
function c54860010.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c54860010.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的名字带有「异虫」的爬虫类族怪兽
function c54860010.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
-- 效果2（自坏）的发动条件函数
function c54860010.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在除这张卡以外的表侧表示「异虫」爬虫类族怪兽
	return not Duel.IsExistingMatchingCard(c54860010.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果2（自坏）的靶向/发动检测函数
function c54860010.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果2（自坏）的效果处理函数
function c54860010.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
