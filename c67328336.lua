--機皇城
-- 效果：
-- ①：自己场上的「机皇帝」怪兽不会成为同调怪兽的效果的对象。
-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只「机皇帝」怪兽加入手卡。
function c67328336.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「机皇帝」怪兽不会成为同调怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上的「机皇帝」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3013))
	e2:SetValue(c67328336.effval)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只「机皇帝」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetDescription(aux.Stringid(67328336,0))  --"检索"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c67328336.thcon)
	e3:SetTarget(c67328336.thtg)
	e3:SetOperation(c67328336.thop)
	c:RegisterEffect(e3)
end
-- 定义不能成为对象的效果来源：判断该效果是否由同调怪兽发动
function c67328336.effval(e,re,rp)
	return re:GetHandler():IsType(TYPE_SYNCHRO)
end
-- 判断发动条件：此卡在场上被破坏并送去墓地
function c67328336.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中属于「机皇帝」怪兽且能加入手牌的卡
function c67328336.filter(c)
	return c:IsSetCard(0x3013) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果发动的目标：检查卡组中是否存在符合条件的卡，并设置检索并加入手牌的操作信息
function c67328336.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67328336.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从自己卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果运行的处理：从卡组选择1只「机皇帝」怪兽加入手牌并给对方确认
function c67328336.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c67328336.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
