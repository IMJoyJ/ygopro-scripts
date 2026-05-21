--方界業
-- 效果：
-- ①：这张卡的发动时，可以以「方界胤 毗贾姆」以外的自己场上1只「方界」怪兽为对象。那个场合，从手卡·卡组把「方界胤 毗贾姆」任意数量送去墓地。那之后，作为对象的怪兽的攻击力上升这个效果送去墓地的怪兽数量×800。
-- ②：对方回合「方界」怪兽的效果让「方界胤 毗贾姆」特殊召唤的场合发动。这张卡送去墓地，对方基本分变成一半。
-- ③：把墓地的这张卡除外才能发动。从卡组把1只「方界」怪兽加入手卡。
function c9659580.initial_effect(c)
	-- ①：这张卡的发动时，可以以「方界胤 毗贾姆」以外的自己场上1只「方界」怪兽为对象。那个场合，从手卡·卡组把「方界胤 毗贾姆」任意数量送去墓地。那之后，作为对象的怪兽的攻击力上升这个效果送去墓地的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9659580.target)
	c:RegisterEffect(e1)
	-- ②：对方回合「方界」怪兽的效果让「方界胤 毗贾姆」特殊召唤的场合发动。这张卡送去墓地，对方基本分变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9659580,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c9659580.lpcon)
	e2:SetOperation(c9659580.lpop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从卡组把1只「方界」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9659580,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c9659580.thtg)
	e3:SetOperation(c9659580.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡·卡组中名为「方界胤 毗贾姆」且能送去墓地的卡
function c9659580.tgfilter(c)
	return c:IsCode(15610297) and c:IsAbleToGrave()
end
-- 过滤条件：场上表侧表示的「方界胤 毗贾姆」以外的「方界」怪兽
function c9659580.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and not c:IsCode(15610297)
end
-- 这张卡发动时的效果处理，判断是否选择自己场上的「方界」怪兽作为对象
function c9659580.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9659580.filter(chkc) end
	if chk==0 then return true end
	-- 检查自己场上是否存在满足对象条件的「方界」怪兽
	if Duel.IsExistingTarget(c9659580.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的手卡·卡组是否存在「方界胤 毗贾姆」
		and Duel.IsExistingMatchingCard(c9659580.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
		-- 询问玩家是否在发动时选择对象
		and Duel.SelectYesNo(tp,aux.Stringid(9659580,0)) then  --"是否以「方界」怪兽为对象发动？"
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c9659580.activate)
		-- 选择自己场上1只「方界胤 毗贾姆」以外的「方界」怪兽作为对象
		Duel.SelectTarget(tp,c9659580.filter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 设置操作信息：将卡组的卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 发动时的效果处理：将任意数量的「方界胤 毗贾姆」送去墓地，并使对象怪兽攻击力上升对应数值
function c9659580.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡·卡组选择任意数量的「方界胤 毗贾姆」
	local g=Duel.SelectMatchingCard(tp,c9659580.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,99,nil)
	-- 将选择的卡因效果送去墓地，并判断是否成功送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		-- 获取实际被操作送去墓地的卡片组
		local og=Duel.GetOperatedGroup()
		local n=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		-- 获取发动时选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and n>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 作为对象的怪兽的攻击力上升这个效果送去墓地的怪兽数量×800。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(n*800)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 效果②的发动条件判定
function c9659580.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 判定是否为对方回合，且是由「方界」怪兽的效果发动
	return Duel.GetTurnPlayer()~=tp and re:IsActiveType(TYPE_MONSTER) and rc and rc:IsSetCard(0xe3)
		and eg:IsExists(Card.IsCode,1,nil,15610297)
end
-- 效果②的效果处理：将这张卡送去墓地，对方基本分变成一半
function c9659580.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果相关，并成功因效果送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 将对方的基本分变成一半
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
-- 过滤条件：卡组中可以加入手卡的「方界」怪兽
function c9659580.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的发动准备与可行性判定
function c9659580.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在可检索的「方界」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9659580.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组将1只「方界」怪兽加入手卡
function c9659580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「方界」怪兽
	local g=Duel.SelectMatchingCard(tp,c9659580.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
