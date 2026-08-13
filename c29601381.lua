--スプリガンズ・キャプテン サルガス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
-- ②：对方回合，把自己场上1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
-- ③：持有这张卡作为素材中的「护宝炮妖」超量怪兽得到以下效果。
-- ●这张卡的攻击力上升500。
function c29601381.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29601381,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCountLimit(1,29601381)
	e1:SetTarget(c29601381.ovtg)
	e1:SetOperation(c29601381.ovop)
	c:RegisterEffect(e1)
	-- ②：对方回合，把自己场上1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29601381,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,29601382)
	e2:SetCondition(c29601381.descon)
	e2:SetCost(c29601381.descost)
	e2:SetTarget(c29601381.destg)
	e2:SetOperation(c29601381.desop)
	c:RegisterEffect(e2)
	-- ③：持有这张卡作为素材中的「护宝炮妖」超量怪兽得到以下效果。●这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29601381,2))
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(500)
	e3:SetCondition(c29601381.gfcon)
	c:RegisterEffect(e3)
end
-- 定义①效果的可选对象过滤器：对象必须是表侧表示、属于「护宝炮妖」系列的超量怪兽。
function c29601381.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- ①效果的目标选择函数：先确认发动时满足条件（我方场上有符合条件的「护宝炮妖」超量怪兽且此卡可作为超量素材），若选择对象则提示玩家并选择1只符合条件的超量怪兽作为对象；此外若此卡在墓地，则登记其离开墓地的操作信息。
function c29601381.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29601381.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件判定：检查我方场上是否存在至少1只符合条件的「护宝炮妖」超量怪兽（此卡本身除外），并且此卡可作为超量素材。
	if chk==0 then return Duel.IsExistingTarget(c29601381.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 向操作者显示提示文字“请选择效果的对象”，并写入选择用缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择我方场上1只符合条件的「护宝炮妖」超量怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c29601381.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若此卡目前在墓地，则登记操作信息：此卡将因效果离开墓地，使「王家长眠之谷」等涉及墓地的效果能够正确响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ①效果处理：确认此卡仍与效果关联、对象仍有效且此卡不免疫此效果后，先将此卡原持有的超量素材（若有）按规则送入墓地，再将此卡作为超量素材叠放到对象超量怪兽下方。
function c29601381.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得此效果的对象卡（之前选定的超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay() then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将此卡如果原本作为超量怪兽时持有的超量素材，以规则理由全部送去墓地，避免额外素材被带入新超量怪兽。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 把这张卡作为超量素材，叠放到对象超量怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- ②效果的发动条件：仅在对方回合可以发动（当前回合玩家不是此卡的控制者）。
function c29601381.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是此卡控制者的对手，即满足“对方回合”的条件。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动代价：从自己场上取除1个超量素材。
function c29601381.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上有至少1个超量素材可供取除。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 实际执行代价：取除自己场上1个超量素材。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- ②效果的目标选择：选择场上1张表侧表示的卡作为破坏对象，并登记破坏的操作信息。
function c29601381.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 目标选择前的合法性检查：确认场上存在至少1张表侧表示的卡可以选择。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张表侧表示的卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁将破坏所选对象，以便其他卡（如「星尘龙」）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：若对象卡仍与效果关联，则将其破坏。
function c29601381.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡（之前选择的表侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以“效果”为原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的赋予条件：作为超量素材时，仅当持有它的超量怪兽为「护宝炮妖」字段的超量怪兽时才适用攻击力上升。
function c29601381.gfcon(e)
	return e:GetHandler():IsSetCard(0x155)
end
