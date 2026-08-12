--オーバーレイ・キャプチャー
-- 效果：
-- 选择对方场上1只持有超量素材的超量怪兽和自己场上1只超量怪兽才能发动。把选择的对方怪兽的超量素材全部取除，把这张卡在选择的自己怪兽下面重叠作为超量素材。
function c74852810.initial_effect(c)
	-- 选择对方场上1只持有超量素材的超量怪兽和自己场上1只超量怪兽才能发动。把选择的对方怪兽的超量素材全部取除，把这张卡在选择的自己怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74852810.target)
	e1:SetOperation(c74852810.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示且持有超量素材的超量怪兽
function c74852810.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 过滤自己场上表侧表示的超量怪兽
function c74852810.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果发动的对象选择与合法性检查
function c74852810.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只表侧表示且持有超量素材的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c74852810.filter1,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示的超量怪兽
		and Duel.IsExistingTarget(c74852810.filter2,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 发送选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只持有超量素材的超量怪兽作为对象
	local g1=Duel.SelectTarget(tp,c74852810.filter1,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 发送选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的超量怪兽作为对象
	Duel.SelectTarget(tp,c74852810.filter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理的执行函数，包含取除素材和将自身重叠为素材的操作
function c74852810.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if not tc1:IsControler(1-tp) or not tc1:IsRelateToEffect(e) then return end
	local og=tc1:GetOverlayGroup()
	if og:GetCount()==0 then return end
	-- 若成功将对方怪兽的超量素材送去墓地，且己方怪兽与此卡仍合法存在，则进行后续处理
	if Duel.SendtoGrave(og,REASON_EFFECT)~=0 and tc2:IsControler(tp) and tc2:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		c:CancelToGrave()
		-- 将这张卡重叠在选择的自己怪兽下面作为超量素材
		Duel.Overlay(tc2,Group.FromCards(c))
	end
end
