--スクラップ・ハンター
-- 效果：
-- 1回合1次，可以选择这张卡以外的自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏，从自己卡组把1只调整送去墓地。
function c55624610.initial_effect(c)
	-- 1回合1次，可以选择这张卡以外的自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏，从自己卡组把1只调整送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55624610,0))  --"破坏并送墓"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c55624610.destg)
	e1:SetOperation(c55624610.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「废铁」怪兽
function c55624610.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 过滤条件：卡组中可以送去墓地的调整怪兽
function c55624610.sfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
end
-- 效果发动的对象选择与可行性检查
function c55624610.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c55624610.desfilter(chkc) end
	-- 检查自己场上是否存在除这张卡以外的表侧表示的「废铁」怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c55624610.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查自己卡组中是否存在可以送去墓地的调整怪兽
		and Duel.IsExistingMatchingCard(c55624610.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上除这张卡以外的1只表侧表示的「废铁」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55624610.desfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：破坏选中的怪兽，并从卡组将1只调整送去墓地
function c55624610.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽在场上表侧表示存在且因该效果成功破坏
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只满足条件的调整怪兽
		local sg=Duel.SelectMatchingCard(tp,c55624610.sfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的调整怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
