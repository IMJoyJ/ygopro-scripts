--英炎星－ホークエイ
-- 效果：
-- 这张卡被对方破坏的场合，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。此外，自己场上有名字带有「炎舞」的魔法·陷阱卡存在的场合，自己场上的全部名字带有「炎星」的怪兽的攻击力·守备力上升500。
function c17475251.initial_effect(c)
	-- 这张卡被对方破坏的场合，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17475251,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c17475251.setcon)
	e1:SetTarget(c17475251.settg)
	e1:SetOperation(c17475251.setop)
	c:RegisterEffect(e1)
	-- 自己场上有名字带有「炎舞」的魔法·陷阱卡存在的场合，自己场上的全部名字带有「炎星」的怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c17475251.atkcon)
	-- 设置效果目标为名字带有「炎星」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x79))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 效果发动条件：破坏时由对方造成，且该卡之前在自己的控制下
function c17475251.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤函数：名字带有「炎舞」的魔法卡，且可以盖放
function c17475251.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果目标：检查场上是否存在满足条件的魔法·陷阱卡
function c17475251.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c17475251.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：选择并盖放一张符合条件的魔法卡
function c17475251.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c17475251.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤函数：场上正面表示的名字带有「炎舞」的魔法·陷阱卡
function c17475251.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动条件：场上存在名字带有「炎舞」的魔法·陷阱卡
function c17475251.atkcon(e)
	-- 检查场上是否存在名字带有「炎舞」的魔法·陷阱卡
	return Duel.IsExistingMatchingCard(c17475251.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
