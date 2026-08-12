--No.47 ナイトメア・シャーク
-- 效果：
-- 3星怪兽×2
-- ①：这张卡特殊召唤成功时才能发动。从手卡以及自己场上的表侧表示怪兽之中选1只水属性·3星怪兽在这张卡下面重叠作为超量素材。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只水属性怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
function c31320433.initial_effect(c)
	-- 为卡片添加等级为3、数量为2的超量召唤手续
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时才能发动。从手卡以及自己场上的表侧表示怪兽之中选1只水属性·3星怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31320433,0))  --"增加素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(c31320433.mattg)
	e1:SetOperation(c31320433.matop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只水属性怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31320433,1))  --"直接攻击"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31320433.dacon)
	e2:SetCost(c31320433.dacost)
	e2:SetTarget(c31320433.datg)
	e2:SetOperation(c31320433.daop)
	c:RegisterEffect(e2)
end
-- 设置该卡的超量编号为47
aux.xyz_number[31320433]=47
-- 定义用于筛选超量素材的过滤函数，条件为：手牌或表侧表示的3星水属性怪兽且可作为超量素材
function c31320433.matfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 判断是否满足①效果的发动条件，即该卡为超量怪兽且自己场上有满足条件的水属性3星怪兽
function c31320433.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查手牌或场上是否存在满足超量素材条件的怪兽
		and Duel.IsExistingMatchingCard(c31320433.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- 执行①效果的处理，选择满足条件的怪兽并将其作为超量素材叠放
function c31320433.matop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择满足条件的1张手牌或场上的水属性3星怪兽作为超量素材
	local g=Duel.SelectMatchingCard(tp,c31320433.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>=0 then
		-- 将选中的卡叠放至该卡下方
		Duel.Overlay(e:GetHandler(),g)
	end
end
-- 判断是否满足②效果的发动条件，即当前回合是否能进入战斗阶段
function c31320433.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- ②效果的费用支付处理，移除该卡1个超量素材
function c31320433.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义用于筛选目标怪兽的过滤函数，条件为：表侧表示的水属性怪兽
function c31320433.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ②效果的目标选择处理，选择1只自己场上的水属性怪兽作为目标
function c31320433.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31320433.filter(chkc) end
	-- 检查自己场上是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c31320433.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的水属性怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只自己场上的水属性怪兽作为目标
	local g=Duel.SelectTarget(tp,c31320433.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果，使除目标怪兽外的所有怪兽不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c31320433.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使除目标怪兽外的所有怪兽不能攻击
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的处理，使目标怪兽获得直接攻击能力
function c31320433.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 使目标怪兽获得直接攻击能力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 用于判断是否为被选中的目标怪兽，防止目标怪兽被禁止攻击
function c31320433.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
