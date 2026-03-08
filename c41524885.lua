--エクソシスター・アソフィール
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。这个回合，双方不能把墓地的卡的效果发动。
-- ②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。
-- ③：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡。
function c41524885.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽作为素材的超量召唤手续
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
	-- ②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c41524885.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c41524885.indval)
	c:RegisterEffect(e3)
	-- 检索满足条件的卡片组，将目标怪兽特殊召唤
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
-- 检查超量召唤时使用的素材是否包含「救祓少女」卡组的怪兽，若包含则设置标签为1，否则为0
function c41524885.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x172) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断该效果是否由超量召唤触发且标签为1
function c41524885.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 创建一个影响双方玩家的永续效果，禁止在本回合发动墓地中的卡的效果
function c41524885.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 禁止发动墓地中的卡的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c41524885.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断效果是否在墓地发动
function c41524885.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
-- 判断效果是否由从墓地特殊召唤的怪兽发动
function c41524885.indval(e,te,rp)
	return te:IsActivated() and te:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 检查是否能移除1个超量素材作为发动代价
function c41524885.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对方场上1只可以送回手牌的怪兽作为效果对象
function c41524885.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 确认场上是否存在可以送回手牌的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定效果处理的分类和目标数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将目标怪兽送回手牌
function c41524885.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
