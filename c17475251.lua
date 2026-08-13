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
	-- 此外，自己场上有名字带有「炎舞」的魔法·陷阱卡存在的场合，自己场上的全部名字带有「炎星」的怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c17475251.atkcon)
	-- 设置该攻击力提升效果的适用对象为持有「炎星」字段（0x79）的怪兽（攻击力提升只对表侧表示怪兽生效）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x79))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 效果发动条件：这张卡被对方破坏，且被破坏前由自己控制。
function c17475251.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 筛选卡组中满足条件的卡：卡名含有「炎舞」（0x7c）、是魔法卡并且可以被盖放到魔法与陷阱区域。
function c17475251.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果发动时的目标检查：确认自己卡组中是否存在至少1张满足filter条件的「炎舞」魔法卡。
function c17475251.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查卡组中是否存在至少1张满足筛选条件的「炎舞」魔法卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17475251.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理时：从卡组选择1张满足条件的「炎舞」魔法卡，盖放到自己魔法与陷阱区域。
function c17475251.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足filter条件的「炎舞」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c17475251.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「炎舞」魔法卡以里侧表示盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 用于检查是否存在表侧表示的名字带有「炎舞」（0x7c）的魔法·陷阱卡。
function c17475251.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 攻击力·守备力上升效果的条件：自己场上有表侧表示的名字带有「炎舞」的魔法·陷阱卡存在。
function c17475251.atkcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的名字带有「炎舞」的魔法·陷阱卡，存在则条件成立。
	return Duel.IsExistingMatchingCard(c17475251.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
