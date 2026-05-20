--突撃指令
-- 效果：
-- ①：以衍生物以外的自己场上1只通常怪兽为对象才能发动。那只通常怪兽解放，选对方场上1只怪兽破坏。
function c78986941.initial_effect(c)
	-- ①：以衍生物以外的自己场上1只通常怪兽为对象才能发动。那只通常怪兽解放，选对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c78986941.target)
	e1:SetOperation(c78986941.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、可被效果解放的非衍生物通常怪兽
function c78986941.rfilter(c,e)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
		and c:IsFaceup() and c:IsReleasableByEffect()
end
-- 靶向与发动条件判断：检查是否存在合法的对象以及对方场上是否有可破坏的怪兽
function c78986941.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c78986941.rfilter(chkc,e) end
	-- 发动检查：自己场上是否存在符合条件的通常怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c78986941.rfilter,tp,LOCATION_MZONE,0,1,nil,e)
		-- 发动检查：对方场上是否存在至少1只怪兽
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只符合条件的通常怪兽作为对象
	local rg=Duel.SelectTarget(tp,c78986941.rfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	-- 获取对方场上所有怪兽的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理信息为破坏对方场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：解放作为对象的怪兽，并选择对方场上1只怪兽破坏
function c78986941.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍表侧表示存在、未受此效果免疫且成功解放
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1只怪兽
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		if dg:GetCount()>0 then
			-- 破坏选中的对方怪兽
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
