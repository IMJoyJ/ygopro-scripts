--ライトロード・エンジェル ケルビム
-- 效果：
-- 把名字带有「光道」的怪兽解放对这张卡的上级召唤成功时，从自己卡组上面把4张卡送去墓地才能发动。选择对方场上最多2张卡破坏。
function c94381039.initial_effect(c)
	-- 把名字带有「光道」的怪兽解放对这张卡的上级召唤成功时，从自己卡组上面把4张卡送去墓地才能发动。选择对方场上最多2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94381039,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c94381039.condition)
	e1:SetCost(c94381039.cost)
	e1:SetTarget(c94381039.target)
	e1:SetOperation(c94381039.operation)
	c:RegisterEffect(e1)
	-- 把名字带有「光道」的怪兽解放对这张卡的上级召唤成功时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c94381039.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查上级召唤的解放素材中是否存在名字带有「光道」的怪兽，并在对应的效果上做标记
function c94381039.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x38) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判定此卡是否上级召唤成功，且解放素材中包含名字带有「光道」的怪兽
function c94381039.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 检查并执行发动代价：从自己卡组上面把4张卡送去墓地
function c94381039.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家是否能将卡组最上方的4张卡送去墓地作为发动代价
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,4) end
	-- 作为发动代价，将自己卡组最上方的4张卡送去墓地
	Duel.DiscardDeck(tp,4,REASON_COST)
end
-- 检查并选择对方场上最多2张卡作为破坏的对象，并设置破坏的操作信息
function c94381039.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判定对方场上是否存在至少1张可以作为对象的效果影响卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1到2张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏作为效果对象的卡片
function c94381039.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 破坏仍存在于场上且与效果相关的对象卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
