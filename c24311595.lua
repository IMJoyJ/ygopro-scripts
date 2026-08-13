--レスキューロイド
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，自己场上存在的名字带有「机人」的怪兽被战斗破坏送去墓地时，可以使那只怪兽回到手卡。
function c24311595.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的名字带有「机人」的怪兽被战斗破坏送去墓地时，可以使那只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24311595,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c24311595.target)
	e1:SetOperation(c24311595.activate)
	c:RegisterEffect(e1)
end
-- 筛选出本次被战斗破坏送去墓地、之前控制者为tp、卡名含有「机人」字段且可以被加入手卡的怪兽。
function c24311595.filter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		and c:IsSetCard(0x16) and c:IsAbleToHand()
end
-- 效果发动时，从诱发事件eg中筛选满足条件的机人怪兽；若存在，将其中一只存入效果LabelObject并允许发动。
function c24311595.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c24311595.filter,nil,tp)
		e:SetLabelObject(g:GetFirst())
		return g:GetCount()~=0
	end
	-- 把存入LabelObject的怪兽设置为当前连锁的对象卡，使其与效果建立关联。
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息：本效果处理时将把1只对象怪兽加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,0,0)
end
-- 处理时确认救援机人仍存在于场上且与效果关联，对象怪兽仍与效果关联，则将其加入手牌。
function c24311595.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中被确定为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 以效果原因将该对象怪兽送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
