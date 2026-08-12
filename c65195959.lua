--EMプラスタートル
-- 效果：
-- ①：1回合1次，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽的等级上升1星。
function c65195959.initial_effect(c)
	-- ①：1回合1次，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65195959,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c65195959.target)
	e1:SetOperation(c65195959.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且具有等级的怪兽
function c65195959.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果①的发动准备，检查并选择场上最多2只表侧表示且有等级的怪兽作为对象
function c65195959.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c65195959.filter(chkc) end
	-- 在发动阶段检查场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c65195959.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置提示信息为选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1到2只满足条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c65195959.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
end
-- 效果①的效果处理，使作为对象的怪兽等级上升1星
function c65195959.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
