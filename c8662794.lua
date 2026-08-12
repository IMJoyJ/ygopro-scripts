--コードブレイカー・ゼロデイ
-- 效果：
-- ①：「代码破坏者」连接怪兽以外的和这张卡连接状态的连接怪兽的攻击力下降1000。
-- ②：这张卡已在怪兽区域存在的状态，场上的「代码破坏者」连接怪兽被战斗·效果破坏的场合发动。这张卡破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「代码破坏者·零日」加入手卡。
function c8662794.initial_effect(c)
	-- ①：「代码破坏者」连接怪兽以外的和这张卡连接状态的连接怪兽的攻击力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c8662794.atktg)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，场上的「代码破坏者」连接怪兽被战斗·效果破坏的场合发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8662794,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c8662794.descon)
	e2:SetTarget(c8662794.destg)
	e2:SetOperation(c8662794.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「代码破坏者·零日」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8662794,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c8662794.srcon)
	e3:SetTarget(c8662794.srtg)
	e3:SetOperation(c8662794.srop)
	c:RegisterEffect(e3)
end
-- 过滤出场上表侧表示、非「代码破坏者」且与自身处于连接状态的连接怪兽
function c8662794.atktg(e,c)
	local lg1=c:GetLinkedGroup()
	local lg2=e:GetHandler():GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and not c:IsSetCard(0x13c)
		and (lg1 and lg1:IsContains(e:GetHandler()) or lg2 and lg2:IsContains(c))
end
-- 过滤出原本在怪兽区域表侧表示、因战斗或效果被破坏的「代码破坏者」连接怪兽
function c8662794.desfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_LINK~=0 and c:IsPreviousSetCard(0x13c)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查被破坏的卡中是否存在满足条件的「代码破坏者」连接怪兽
function c8662794.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c8662794.desfilter,1,nil)
end
-- 效果②的发动准备，设置破坏自身的操作信息
function c8662794.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- 效果②的效果处理，若自身在场则将自身破坏
function c8662794.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 效果③的发动条件，自身被战斗或效果破坏
function c8662794.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤卡组中卡名为「代码破坏者·零日」且能加入手牌的卡
function c8662794.srfilter(c)
	return c:IsCode(8662794) and c:IsAbleToHand()
end
-- 效果③的发动准备，检查卡组中是否存在「代码破坏者·零日」并设置检索操作信息
function c8662794.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查我方卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8662794.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从我方卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理，从卡组选择1只「代码破坏者·零日」加入手牌并给对方确认
function c8662794.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从我方卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c8662794.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 因效果将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
