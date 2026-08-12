--EMモンキーボード
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有「娱乐伙伴」卡存在的场合，这张卡的灵摆刻度变成4。
-- ②：这张卡发动的回合的自己主要阶段才能发动。从卡组把1只4星以下的「娱乐伙伴」怪兽加入手卡。
-- 【怪兽效果】
-- ①：把这张卡从手卡丢弃才能发动。手卡1只「娱乐伙伴」怪兽或「异色眼」怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
function c17330916.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：另一边的自己的灵摆区域没有「娱乐伙伴」卡存在的场合，这张卡的灵摆刻度变成4。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c17330916.reg)
	c:RegisterEffect(e1)
	-- ②：这张卡发动的回合的自己主要阶段才能发动。从卡组把1只4星以下的「娱乐伙伴」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c17330916.sccon)
	e2:SetValue(4)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e3)
	-- ①：把这张卡从手卡丢弃才能发动。手卡1只「娱乐伙伴」怪兽或「异色眼」怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17330916,0))  --"降低等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1)
	e4:SetCost(c17330916.lvcost)
	e4:SetTarget(c17330916.lvtg)
	e4:SetOperation(c17330916.lvop)
	c:RegisterEffect(e4)
	-- 这个卡名的②的灵摆效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCountLimit(1,17330916)
	e5:SetCondition(c17330916.thcon)
	e5:SetTarget(c17330916.thtg)
	e5:SetOperation(c17330916.thop)
	c:RegisterEffect(e5)
end
-- 判断另一边的自己的灵摆区域是否存在「娱乐伙伴」卡
function c17330916.sccon(e)
	-- 若另一边的自己的灵摆区域没有「娱乐伙伴」卡，则返回true
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0x9f)
end
-- 注册flag标记，用于记录该卡已发动过②的灵摆效果
function c17330916.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(17330916,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断该卡是否已发动过②的灵摆效果
function c17330916.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17330916)~=0
end
-- 过滤函数，用于筛选4星以下且为「娱乐伙伴」卡的怪兽
function c17330916.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9f) and c:IsAbleToHand()
end
-- 设置连锁操作信息，用于检索满足条件的卡
function c17330916.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c17330916.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定要处理的卡为1张手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索满足条件的卡并加入手牌
function c17330916.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c17330916.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 丢弃此卡以发动效果
function c17330916.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡丢入墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD)
end
-- 过滤函数，用于筛选「娱乐伙伴」或「异色眼」怪兽
function c17330916.filter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(2)
end
-- 设置连锁操作信息，用于选择要降低等级的怪兽
function c17330916.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c17330916.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
-- 过滤函数，用于筛选指定编号的卡
function c17330916.afilter(c,code)
	return c:IsCode(code)
end
-- 处理等级下降效果
function c17330916.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c17330916.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
	-- 获取与所选卡同名的手牌
	local hg=Duel.GetMatchingGroup(c17330916.afilter,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
	local tc=hg:GetFirst()
	while tc do
		-- 为所选卡及其同名卡设置等级下降效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
