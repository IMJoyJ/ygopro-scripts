--EMモンキーボード
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有「娱乐伙伴」卡存在的场合，这张卡的灵摆刻度变成4。
-- ②：这张卡发动的回合的自己主要阶段才能发动。从卡组把1只4星以下的「娱乐伙伴」怪兽加入手卡。
-- 【怪兽效果】
-- ①：把这张卡从手卡丢弃才能发动。手卡1只「娱乐伙伴」怪兽或「异色眼」怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
function c17330916.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（使其可作为灵摆召唤、进入灵摆区），但不注册灵摆卡的“发动”效果，由下方e1自行处理。
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡发动的回合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c17330916.reg)
	c:RegisterEffect(e1)
	-- 这张卡的灵摆刻度变成4。
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
	-- ②：这张卡发动的回合的自己主要阶段才能发动。从卡组把1只4星以下的「娱乐伙伴」怪兽加入手卡。
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
-- sccon：判断另一个灵摆区域是否不存在「娱乐伙伴」卡，若不存在则刻度变化条件成立。
function c17330916.sccon(e)
	-- 检查自己灵摆区除自身外没有0x9f系列的卡，返回真值用于刻度变化条件。
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0x9f)
end
-- reg：作为手卡发动灵摆卡时的cost，无条件允许，并给自身登记一个到结束阶段有效的誓约标记（17330916），用于表示本回合发动过这张灵摆卡。
function c17330916.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(17330916,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- thcon：检索效果的发动条件，必须本回合已经发动过这张灵摆卡（存在标记17330916）才允许发动。
function c17330916.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17330916)~=0
end
-- thfilter：检索卡的过滤条件：等级4以下、属于「娱乐伙伴」（0x9f）系列、且能加入手卡。
function c17330916.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9f) and c:IsAbleToHand()
end
-- thtg：检索效果发动前确认卡组中有符合条件的卡，并设置本次连锁的操作信息为从卡组检索1张卡。
function c17330916.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组是否存在至少1张满足thfilter的卡，以此作为效果可否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c17330916.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果包含将1张卡从卡组加入手卡，不指定具体对象。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- thop：效果处理时从卡组选择1张满足条件的「娱乐伙伴」怪兽加入手卡，并给对方确认。
function c17330916.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 在卡组中筛选并选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c17330916.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把刚刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- lvcost：丢弃手卡中的这张卡作为发动cost，检查其可以丢弃后实际送去墓地。
function c17330916.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡以丢弃原因从手卡送去墓地，完成cost。
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD)
end
-- filter：选择手卡怪兽的条件：属于「娱乐伙伴」或「异色眼」系列、是怪兽、且等级在2以上。
function c17330916.filter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(2)
end
-- lvtg：效果发动条件：手卡中存在除了这张卡以外的至少1只符合filter的怪兽可供展示。
function c17330916.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手卡中是否存在至少1只满足filter的怪兽，以决定能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17330916.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
-- afilter：按指定卡号匹配手卡中的卡，用于筛选与展示怪兽同名的卡。
function c17330916.afilter(c,code)
	return c:IsCode(code)
end
-- lvop：效果处理：从手卡选1只「娱乐伙伴」或「异色眼」怪兽给对方确认，随后洗切手卡，并给手卡中所有与该怪兽同名的卡附加等级下降1星的效果（直到结束阶段）。
function c17330916.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示：请选择给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择1张符合条件的怪兽卡，作为展示给对方的那只怪兽。
	local g=Duel.SelectMatchingCard(tp,c17330916.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽展示给对方玩家。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡，重置因选择/展示可能造成的手卡顺序变动。
	Duel.ShuffleHand(tp)
	-- 获取手卡中所有卡名与刚才展示怪兽相同的卡，用于后续等级下降处理。
	local hg=Duel.GetMatchingGroup(c17330916.afilter,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
	local tc=hg:GetFirst()
	while tc do
		-- 这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
