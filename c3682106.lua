--ダブルトラップ
-- 效果：
-- 破坏场上表侧表示存在的含有（陷阱的效果无效化的效果）的1张卡。
function c3682106.initial_effect(c)
	-- 破坏场上表侧表示存在的含有（陷阱的效果无效化的效果）的1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3682106.target)
	e1:SetOperation(c3682106.activate)
	c:RegisterEffect(e1)
end
c3682106.collection={
	[40867519]=true;[67750322]=true;[73551138]=true;[01953925]=true;[65403020]=true;
	[77585513]=true;[35803249]=true;[94568601]=true;[74841885]=true;[66235877]=true;
	[19312169]=true;[51452091]=true;[92408984]=true;[62892347]=true;[42868711]=true;
	[90464188]=true;[03370104]=true;[88989706]=true;[20529766]=true;[53347303]=true;
	[06150044]=true;[49868263]=true;[51447164]=true;[44155002]=true;[74593218]=true;
}
-- 过滤条件：对象必须是场上表侧表示，且卡号属于预定义的含有“使陷阱效果无效化的效果”的卡片列表。
function c3682106.filter(c)
	return c:IsFaceup() and c3682106.collection[c:GetCode()]
end
-- 发动时的目标选择处理：检查是否存在合法对象，提示玩家选择1张符合条件的场上表侧表示卡作为对象，并设置破坏操作信息。
function c3682106.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c3682106.filter(chkc) end
	-- 效果发动时检查：场上是否存在至少1张满足过滤条件且不是本卡的卡片，作为能否发动的判定依据。
	if chk==0 then return Duel.IsExistingTarget(c3682106.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择1张满足过滤条件的表侧表示卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c3682106.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 将本次操作的类别设置为破坏，目标为已选择的卡，数量为1，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：取得连锁对象，若该对象仍在场上表侧表示且与本效果有联系，则将其破坏。
function c3682106.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果连锁处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
