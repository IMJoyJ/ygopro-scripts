--RR－トリビュート・レイニアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动。从卡组把1张「急袭猛禽」卡送去墓地。
-- ②：这张卡战斗破坏对方怪兽的回合的自己主要阶段2才能发动。从卡组把1张「升阶魔法」速攻魔法卡加入手卡。这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能特殊召唤。
function c83236601.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动。从卡组把1张「急袭猛禽」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83236601,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,83236601)
	e1:SetCondition(c83236601.tgcon)
	e1:SetTarget(c83236601.tgtg)
	e1:SetOperation(c83236601.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c83236601.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽的回合的自己主要阶段2才能发动。从卡组把1张「升阶魔法」速攻魔法卡加入手卡。这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83236601,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,83236602)
	e3:SetCondition(c83236601.thcon)
	e3:SetTarget(c83236601.thtg)
	e3:SetOperation(c83236601.thop)
	c:RegisterEffect(e3)
	if not c83236601.global_check then
		c83236601.global_check=true
		-- ①：这张卡召唤·特殊召唤的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(83236601)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局事件的处理函数为：标记召唤成功的卡片
		ge1:SetOperation(aux.sumreg)
		-- 注册全局效果：监听通常召唤成功事件
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(83236601)
		-- 注册全局效果：监听特殊召唤成功事件
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果①的发动条件：这张卡在本回合召唤·特殊召唤过
function c83236601.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(83236601)>0
end
-- 过滤条件：卡组中的「急袭猛禽」卡且能送去墓地
function c83236601.tgfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToGrave()
end
-- 效果①的发动准备：确认卡组中存在可送去墓地的「急袭猛禽」卡，向对方展示发动效果，并设置送去墓地的操作信息
function c83236601.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「急袭猛禽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c83236601.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：让玩家从卡组选择1张「急袭猛禽」卡送去墓地
function c83236601.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「急袭猛禽」卡
	local g=Duel.SelectMatchingCard(tp,c83236601.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 战斗破坏怪兽时的处理：给自身注册一个在本回合结束前有效的标记，用于记录战斗破坏过怪兽
function c83236601.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(83236602,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：这张卡在本回合战斗破坏过对方怪兽，且当前为自己主要阶段2
function c83236601.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否有战斗破坏怪兽的标记，且当前阶段为主要阶段2
	return e:GetHandler():GetFlagEffect(83236602)>0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：卡组中的「升阶魔法」速攻魔法卡且能加入手卡
function c83236601.filter(c)
	return c:IsSetCard(0x95) and c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY and c:IsAbleToHand()
end
-- 效果②的发动准备：确认卡组中存在可检索的「升阶魔法」速攻魔法卡，向对方展示发动效果，并设置检索的操作信息
function c83236601.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「升阶魔法」速攻魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c83236601.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：将卡组的「升阶魔法」速攻魔法卡加入手卡，并适用直到回合结束时自己不是「急袭猛禽」怪兽不能特殊召唤的限制
function c83236601.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「升阶魔法」速攻魔法卡
	local g=Duel.SelectMatchingCard(tp,c83236601.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c83236601.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：限制玩家本回合后续的特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制条件：非「急袭猛禽」怪兽不能特殊召唤
function c83236601.splimit(e,c)
	return not c:IsSetCard(0xba)
end
