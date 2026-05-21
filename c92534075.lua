--魔弾－デビルズ・ディール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「魔弹」怪兽不会被效果破坏。
-- ②：这张卡被对方的效果送去墓地的场合才能发动。从自己的卡组·墓地选「魔弹-恶魔交易」以外的1张「魔弹」卡加入手卡。
function c92534075.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92534075+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「魔弹」怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上卡名含有「魔弹」的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方的效果送去墓地的场合才能发动。从自己的卡组·墓地选「魔弹-恶魔交易」以外的1张「魔弹」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92534075,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c92534075.thcon)
	e3:SetTarget(c92534075.thtg)
	e3:SetOperation(c92534075.thop)
	c:RegisterEffect(e3)
end
-- 检查发动条件：此卡在自己控制下因对方的效果被送去墓地。
function c92534075.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 过滤条件：卡组或墓地中「魔弹-恶魔交易」以外的「魔弹」卡，且该卡可以加入手牌。
function c92534075.thfilter(c)
	return c:IsSetCard(0x108) and not c:IsCode(92534075) and c:IsAbleToHand()
end
-- 效果发动的靶向与操作信息注册函数。
function c92534075.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c92534075.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息为：将1张卡从卡组或墓地加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：从卡组或墓地将1张「魔弹」卡加入手牌。
function c92534075.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示信息，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地中选择1张满足过滤条件（并应用王家长眠之谷过滤）的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c92534075.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
