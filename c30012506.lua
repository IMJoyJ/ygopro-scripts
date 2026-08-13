--A－アサルト・コア
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族·光属性怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽不受其他的对方怪兽的效果影响。
-- ③：这张卡从场上送去墓地的场合才能发动。自己墓地1只其他的同盟怪兽加入手卡。
function c30012506.initial_effect(c)
	-- 为这张卡注册同盟怪兽通用效果，使其可以作为装备魔法装备给自己场上的机械族·光属性怪兽，并获得装备怪兽被战斗/效果破坏时代为破坏及装备状态下特殊召唤等同盟共通能力；filter指定可装备对象为机械族·光属性怪兽。
	aux.EnableUnionAttribute(c,c30012506.filter)
	-- ②：装备怪兽不受其他的对方怪兽的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c30012506.efilter)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上送去墓地的场合才能发动。自己墓地1只其他的同盟怪兽加入手卡。
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
-- 定义同盟装备的合法对象条件：怪兽必须是机械族且光属性，用于辅助选择和装备处理。
function c30012506.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 定义免疫效果的过滤条件：该效果必须来自对方玩家、不是本卡自身的效果，且为怪兽效果，从而实现对‘其他的对方怪兽的效果’免疫。
function c30012506.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActiveType(TYPE_MONSTER)
end
-- 判定③的发动条件：这张卡送去墓地之前位于场上，即从场上（怪兽区域或魔法陷阱区域）被送去墓地。
function c30012506.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义③检索对象的过滤条件：必须是同盟怪兽，并且可以被加入手卡（排除本卡的操作在调用时通过extra参数完成）。
function c30012506.thfilter(c)
	return c:IsType(TYPE_UNION) and c:IsAbleToHand()
end
-- 设置③的发动目标：在发动合法性检查时确认墓地存在符合条件且不是本卡的同盟怪兽，并登记操作信息为从墓地回收卡片到手卡。
function c30012506.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认自己墓地存在至少1张满足thfilter且不是本卡的同盟怪兽，以允许效果发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30012506.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向连锁系统登记本效果的操作信息：将进行把墓地1张卡加入手卡的处理，供其他卡与规则互动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理时的实际操作：让玩家从自己墓地的其他同盟怪兽中选择1张加入手卡，并向对方展示。
function c30012506.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示当前玩家选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的符合条件的同盟怪兽中选择1张（排除本卡）作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c30012506.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去其持有者的手卡，完成回收。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将回收的卡展示给对方玩家确认，保证信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
