--エクソシスター・アソフィール
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。这个回合，双方不能把墓地的卡的效果发动。
-- ②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。
-- ③：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡。
function c41524885.initial_effect(c)
	-- 为这张卡添加超量召唤规则：需要2只等级4的怪兽作为素材（不限制素材种族/属性）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。这个回合，双方不能把墓地的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41524885,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,41524885)
	e1:SetCondition(c41524885.con)
	e1:SetOperation(c41524885.op)
	c:RegisterEffect(e1)
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c41524885.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c41524885.indval)
	c:RegisterEffect(e3)
	-- ③：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41524885,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,41524886)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c41524885.thcost)
	e4:SetTarget(c41524885.thtg)
	e4:SetOperation(c41524885.thop)
	c:RegisterEffect(e4)
end
-- 检查本次超量召唤使用的素材中是否存在「救祓少女」怪兽（0x172），并将结果记录到①效果的标签中（1为存在，0为不存在）。
function c41524885.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x172) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ①效果的发动条件：这张卡以超量召唤方式成功特殊召唤，且素材检查标签为1（即使用了「救祓少女」怪兽作为素材）。
function c41524885.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- ①效果处理时：创建并注册一个全场适用的效果，使双方玩家这个回合内不能发动墓地卡的效果。
function c41524885.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合，双方不能把墓地的卡的效果发动。②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。③：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c41524885.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新生成的‘禁止墓地效果发动’的效果注册到当前回合玩家tp，使其对双方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 判定某个效果的发动位置是否为墓地；若是墓地则返回true，表示该效果被禁止发动。
function c41524885.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
-- 判定发动效果的怪兽是否为从墓地特殊召唤的怪兽且该效果为已发动效果；若是则本卡不会被该效果破坏。
function c41524885.indval(e,te,rp)
	return te:IsActivated() and te:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- ③效果的发动代价：检查并取除这张卡的1个超量素材。
function c41524885.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果的发动目标选择：选择对方场上1只可加入手卡的怪兽为对象，并设置操作信息。
function c41524885.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在至少1只可以加入手卡的怪兽，作为③效果可否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示提示信息，提示内容为‘请选择要返回手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1只可加入手卡的怪兽，并将其登记为当前效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本效果处理时会将对象怪兽加入手卡的信息，供其他卡/效果参考（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理时：将所选对象怪兽返回持有者手卡；若对象已不相关则不作处理。
function c41524885.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果过程中选择的第一只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送回到其持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
