--捷炎星－セイヴン
-- 效果：
-- 这张卡从场上送去墓地的场合，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。此外，只要这张卡在场上表侧表示存在，自己场上的名字带有「炎舞」的魔法·陷阱卡不会被对方的卡的效果破坏。
function c44860890.initial_effect(c)
	-- 这张卡从场上送去墓地的场合，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44860890,0))  --"盖放"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c44860890.setcon)
	e1:SetTarget(c44860890.settg)
	e1:SetOperation(c44860890.setop)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上表侧表示存在，自己场上的名字带有「炎舞」的魔法·陷阱卡不会被对方的卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c44860890.indtg)
	e2:SetValue(c44860890.indval)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡是从场上送去墓地
function c44860890.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：名字带有「炎舞」且为魔法卡且可以盖放
function c44860890.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果发动时点：检查卡组是否存在满足条件的魔法卡
function c44860890.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44860890.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：选择并盖放一张满足条件的魔法卡
function c44860890.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c44860890.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 判断目标是否为表侧表示的「炎舞」魔法·陷阱卡
function c44860890.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 返回值：若对方控制此卡则该效果不生效
function c44860890.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
