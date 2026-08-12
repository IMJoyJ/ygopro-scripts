--ダーク・スパイダー
-- 效果：
-- 1回合1次，可以把自己场上表侧表示存在的1只昆虫族怪兽的等级直到结束阶段时上升2星。
function c81759748.initial_effect(c)
	-- 1回合1次，可以把自己场上表侧表示存在的1只昆虫族怪兽的等级直到结束阶段时上升2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81759748,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c81759748.target)
	e1:SetOperation(c81759748.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、昆虫族且等级在1以上的怪兽
function c81759748.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsLevelAbove(1)
end
-- 效果发动的对象选择与合法性判定
function c81759748.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81759748.filter(chkc) end
	-- 检查自己场上是否存在满足条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c81759748.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的昆虫族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81759748.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选中的怪兽等级直到结束阶段时上升2星
function c81759748.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRace(RACE_INSECT) then
		-- 等级直到结束阶段时上升2星
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2)
		tc:RegisterEffect(e1)
	end
end
