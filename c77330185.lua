--XX－セイバー ガルセム
-- 效果：
-- 场上存在的这张卡被卡的效果破坏送去墓地时，从自己卡组把1只名字带有「X-剑士」的怪兽加入手卡。这张卡的攻击力上升自己场上表侧表示存在的名字带有「X-剑士」的怪兽数量×200的数值。
function c77330185.initial_effect(c)
	-- 场上存在的这张卡被卡的效果破坏送去墓地时，从自己卡组把1只名字带有「X-剑士」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77330185,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c77330185.condition)
	e1:SetTarget(c77330185.target)
	e1:SetOperation(c77330185.operation)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己场上表侧表示存在的名字带有「X-剑士」的怪兽数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c77330185.atkval)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且名字带有「X-剑士」的卡
function c77330185.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 计算攻击力上升数值的函数
function c77330185.atkval(e,c)
	-- 获取自己场上表侧表示的「X-剑士」怪兽数量并乘以200作为攻击力上升值
	return Duel.GetMatchingGroupCount(c77330185.atfilter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end
-- 触发条件：此卡在场上被卡的效果破坏并送去墓地
function c77330185.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中名字带有「X-剑士」的怪兽且能加入手牌
function c77330185.filter(c)
	return c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与操作信息注册
function c77330185.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只可检索的「X-剑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77330185.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理：从卡组选择1只「X-剑士」怪兽加入手牌并给对方确认
function c77330185.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示信息，要求玩家选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并让玩家选择1张符合条件的「X-剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c77330185.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
