--炎斬機マグマ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡战斗破坏怪兽时，以对方场上最多2张卡为对象才能发动。那些卡破坏。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
function c15248594.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意调整）和1只以上调整以外的怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏怪兽时，以对方场上最多2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15248594,0))  --"卡片破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,15248594)
	-- 设置效果①的发动条件：此卡与本次战斗有关（即此卡战斗破坏怪兽时）。
	e1:SetCondition(aux.bdcon)
	e1:SetTarget(c15248594.destg)
	e1:SetOperation(c15248594.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15248594,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,15248595)
	e2:SetCondition(c15248594.thcon)
	e2:SetTarget(c15248594.thtg)
	e2:SetOperation(c15248594.thop)
	c:RegisterEffect(e2)
end
-- 效果①的对象选择处理函数：在发动时选择对方场上1～2张卡作为对象，并设置破坏的操作信息。
function c15248594.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动合法性检查：确认对方场上是否存在至少1张可被选择为对象的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1～2张卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置连锁操作信息：本次效果将破坏选择的对象卡，数量为对象卡数，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理函数：获取连锁对象，筛选出仍与效果关联的卡，并将其破坏。
function c15248594.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁上登记的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果原因破坏筛选出的对象卡。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被战斗破坏，或被对方的效果破坏且破坏前由我方控制时满足。
function c15248594.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 检索筛选条件：卡名为「斩机」字段、类型为魔法·陷阱卡且可以被加入手卡。
function c15248594.thfilter(c)
	return c:IsSetCard(0x132) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的目标处理函数：确认卡组存在符合条件的卡，并设置检索加入手牌的操作信息。
function c15248594.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中是否存在至少1张符合条件的「斩机」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c15248594.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：预计从卡组将1张卡加入手牌，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数：从卡组选择1张符合条件的「斩机」魔法·陷阱卡加入手牌，并让对方确认。
function c15248594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「斩机」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c15248594.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
