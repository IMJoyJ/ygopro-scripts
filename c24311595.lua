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
-- 过滤满足条件的被战斗破坏送入墓地的怪兽，这些怪兽必须在墓地、由战斗破坏、是自己控制者、名字带有「机人」、可以送入手卡。
function c24311595.filter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		and c:IsSetCard(0x16) and c:IsAbleToHand()
end
-- 设置连锁处理的目标卡为符合条件的怪兽，并设置操作信息为回手牌效果。
function c24311595.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c24311595.filter,nil,tp)
		e:SetLabelObject(g:GetFirst())
		return g:GetCount()~=0
	end
	-- 将目标卡设置为当前处理的连锁对象。
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息为将目标卡送入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,0,0)
end
-- 当效果发动时，检查效果是否有效且目标卡是否存在，若存在则将目标卡送入手卡。
function c24311595.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果为原因送入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
