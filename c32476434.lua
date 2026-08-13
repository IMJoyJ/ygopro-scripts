--ラインモンスター スピア・ホイール
-- 效果：
-- 1回合1次，选择这张卡以外的自己场上1只兽战士族·3星怪兽才能发动。选择的怪兽和这张卡变成各自等级合计的等级。
function c32476434.initial_effect(c)
	-- 1回合1次，选择这张卡以外的自己场上1只兽战士族·3星怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32476434,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c32476434.target)
	e1:SetOperation(c32476434.operation)
	c:RegisterEffect(e1)
end
-- 过滤出符合条件的对象：场上表侧表示、等级3、兽战士族的怪兽（用于选择对象）。
function c32476434.filter(c)
	return c:IsFaceup() and c:IsLevel(3) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 目标选择处理：检查是否存在合法对象，并提示玩家选择一张符合条件且不是发动效果这张卡的兽战士族·3星怪兽作为效果对象。
function c32476434.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c32476434.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动时合法性检查：确认自己场上存在至少1只可被选择的符合条件的对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c32476434.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作玩家显示选择对象的提示消息：“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的兽战士族·3星怪兽作为效果对象（不能选择发动效果的这张卡），并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c32476434.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：若发动效果的这张卡和目标怪兽仍与效果相关且均为表侧表示，则把两者的等级分别变为双方当前等级之和。
function c32476434.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 选择的怪兽和这张卡变成各自等级合计的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
