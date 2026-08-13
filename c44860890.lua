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
-- e1的发动条件：判断这张卡在送去墓地之前是否位于场上（从场上区域被送去墓地）；若是，则满足“这张卡从场上送去墓地的场合”的触发条件。
function c44860890.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选条件：候选卡必须持有「炎舞」字段、是魔法卡，并且当前可以被盖放到魔法与陷阱区域（满足盖放限制）。
function c44860890.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- e1的发动目标检查：在发动时判断自己卡组是否存在至少1张满足c44860890.filter的「炎舞」魔法卡；若不存在则不能发动。
function c44860890.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性判定：检查自己卡组是否有符合条件的「炎舞」魔法卡，有则返回true允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44860890.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- e1效果处理：提示玩家选择要盖放的卡，从卡组选择1张符合条件的「炎舞」魔法卡；若选到则将其盖放到自己场上。
function c44860890.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家发送选择提示信息，使后续选择框显示“请选择要盖放的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组中精确选择1张满足c44860890.filter的「炎舞」魔法卡，选择结果存入g。
	local g=Duel.SelectMatchingCard(tp,c44860890.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的那1张「炎舞」魔法卡由当前玩家盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 保护对象筛选：判断需要接受保护判定的卡片是否为表侧表示、持有「炎舞」字段且为魔法·陷阱卡；满足条件才受e2保护。
function c44860890.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 保护条件判定：若试图破坏的效果由这张卡的控制者的对方玩家发动（即e:GetHandler():GetControler()不等于效果发动者tp），则返回true，使该效果不能破坏受保护的「炎舞」魔法·陷阱卡，体现“不会被对方的卡的效果破坏”。
function c44860890.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
