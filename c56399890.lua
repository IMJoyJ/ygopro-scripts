--魔轟神獣キャシー
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合，以场上1张表侧表示卡为对象发动。那张表侧表示卡破坏。
function c56399890.initial_effect(c)
	-- ①：这张卡从手卡丢弃去墓地的场合，以场上1张表侧表示卡为对象发动。那张表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56399890,0))  --"表侧表示存在的1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c56399890.descon)
	e1:SetTarget(c56399890.destg)
	e1:SetOperation(c56399890.desop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡是否是从手卡被丢弃送去墓地。
function c56399890.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 过滤条件：筛选场上表侧表示的卡。
function c56399890.filter(c)
	return c:IsFaceup()
end
-- 效果的目标选择与操作信息设置：确认合法的对象并选择场上1张表侧表示的卡。
function c56399890.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c56399890.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c56399890.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，声明该效果会破坏选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：如果对象卡仍然表侧表示存在，则将其破坏。
function c56399890.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 通过效果将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
