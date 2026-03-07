--A－アサルト・コア
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族·光属性怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽不受其他的对方怪兽的效果影响。
-- ③：这张卡从场上送去墓地的场合才能发动。自己墓地1只其他的同盟怪兽加入手卡。
function c30012506.initial_effect(c)
	-- 为卡片注册同盟怪兽机制，使其具备装备、代替破坏、特殊召唤等效果，装备对象需满足filter条件
	aux.EnableUnionAttribute(c,c30012506.filter)
	-- 装备怪兽不受其他的对方怪兽的效果影响
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c30012506.efilter)
	c:RegisterEffect(e4)
	-- 这张卡从场上送去墓地的场合才能发动。自己墓地1只其他的同盟怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c30012506.thcon)
	e5:SetTarget(c30012506.thtg)
	e5:SetOperation(c30012506.thop)
	c:RegisterEffect(e5)
end
c30012506.has_text_type=TYPE_UNION
-- 定义装备对象需满足的条件：机械族且光属性
function c30012506.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果免疫函数，使装备怪兽不受对方怪兽的效果影响
function c30012506.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActiveType(TYPE_MONSTER)
end
-- 判断此卡是否从场上送去墓地，用于触发效果
function c30012506.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索满足条件的同盟怪兽，用于加入手牌
function c30012506.thfilter(c)
	return c:IsType(TYPE_UNION) and c:IsAbleToHand()
end
-- 设置效果处理信息，确定要处理的卡为墓地中的同盟怪兽
function c30012506.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地是否存在满足条件的同盟怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30012506.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息，指定要处理的卡为1张墓地中的同盟怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，选择并把符合条件的同盟怪兽加入手牌
function c30012506.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地中选择1张满足条件的同盟怪兽
	local g=Duel.SelectMatchingCard(tp,c30012506.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的同盟怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
