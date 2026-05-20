--深淵の青眼龍
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，若非自己的场上或墓地有「青眼白龙」存在的场合则不能发动。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张仪式魔法卡或「融合」加入手卡。
-- ②：自己结束阶段才能发动。从卡组把1只8星以上的龙族怪兽加入手卡。
-- ③：把墓地的这张卡除外才能发动。自己场上的全部8星以上的龙族怪兽的攻击力上升1000。
function c64202399.initial_effect(c)
	-- 在卡组中记录该卡关联「青眼白龙」卡片密码
	aux.AddCodeList(c,89631139)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张仪式魔法卡或「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64202399,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,64202399)
	e1:SetCondition(c64202399.condition)
	e1:SetTarget(c64202399.thtg1)
	e1:SetOperation(c64202399.thop1)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段才能发动。从卡组把1只8星以上的龙族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64202399,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,64202400)
	e2:SetCondition(c64202399.thcon2)
	e2:SetTarget(c64202399.thtg2)
	e2:SetOperation(c64202399.thop2)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。自己场上的全部8星以上的龙族怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64202399,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,64202401)
	e3:SetCondition(c64202399.condition)
	-- 设置发动效果的Cost为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c64202399.atktg)
	e3:SetOperation(c64202399.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示或墓地存在的「青眼白龙」
function c64202399.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(89631139)
end
-- 效果发动条件：自己的场上或墓地有「青眼白龙」存在
function c64202399.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上或墓地是否存在至少1张「青眼白龙」
	return Duel.IsExistingMatchingCard(c64202399.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 过滤条件：卡组中可以加入手牌的仪式魔法卡或「融合」
function c64202399.thfilter1(c)
	return (c:GetType()==TYPE_RITUAL+TYPE_SPELL or c:IsCode(24094653)) and c:IsAbleToHand()
end
-- 效果①的发动准备与操作信息注册
function c64202399.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的仪式魔法卡或「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c64202399.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张仪式魔法卡或「融合」加入手牌
function c64202399.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的仪式魔法卡或「融合」
	local g=Duel.SelectMatchingCard(tp,c64202399.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：自己的结束阶段，且场上或墓地有「青眼白龙」存在
function c64202399.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且满足「青眼白龙」在场上或墓地存在的条件
	return Duel.GetTurnPlayer()==tp and c64202399.condition(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤条件：卡组中可以加入手牌的8星以上的龙族怪兽
function c64202399.thfilter2(c)
	return c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果②的发动准备与操作信息注册
function c64202399.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的8星以上的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64202399.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只8星以上的龙族怪兽加入手牌
function c64202399.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的8星以上的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c64202399.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的8星以上的龙族怪兽
function c64202399.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON)
end
-- 效果③的发动准备
function c64202399.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的8星以上的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64202399.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果③的效果处理：使自己场上全部8星以上的龙族怪兽的攻击力上升1000
function c64202399.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上全部表侧表示的8星以上的龙族怪兽
	local g=Duel.GetMatchingGroup(c64202399.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部8星以上的龙族怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
