--No.47 ナイトメア・シャーク
-- 效果：
-- 3星怪兽×2
-- ①：这张卡特殊召唤成功时才能发动。从手卡以及自己场上的表侧表示怪兽之中选1只水属性·3星怪兽在这张卡下面重叠作为超量素材。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只水属性怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
function c31320433.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只3星怪兽叠放作为超量素材来超量召唤。
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
-- 设置这张卡的超量编号为47，即卡名中的“No.47”。
aux.xyz_number[31320433]=47
-- 素材过滤条件：从手卡或自己场上表侧表示怪兽中选出水属性·3星、可作为超量素材且不免疫该效果的怪兽。
function c31320433.matfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果①的发动条件：这张卡为超量怪兽，且自己手卡/场上存在符合素材条件的怪兽。
function c31320433.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查手卡和自己怪兽区是否存在至少1只满足素材过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c31320433.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- 效果①的发动处理：从手卡和自己场上表侧表示怪兽中选择1只水属性·3星怪兽，叠放到这张卡下面作为超量素材。
function c31320433.matop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 弹出发动时的选择提示，提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让发动玩家从手卡和自己怪兽区选出1只满足素材条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c31320433.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>=0 then
		-- 将选择到的怪兽重叠放置到这张卡下面，作为这张卡的超量素材。
		Duel.Overlay(e:GetHandler(),g)
	end
end
-- 效果②的发动条件：当前回合可以进入战斗阶段。
function c31320433.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否可以进入战斗阶段，作为效果②的发动的限制条件。
	return Duel.IsAbleToEnterBP()
end
-- 效果②的发动代价：从这张卡上取除1个超量素材（作为COST）。
function c31320433.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②对象的选择条件：自己场上表侧表示且水属性的怪兽。
function c31320433.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的发动时处理：选择自己场上1只水属性怪兽作为对象，并对其他自己场上怪兽施加本回合不能攻击的誓约效果。
function c31320433.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31320433.filter(chkc) end
	-- 检查自己场上是否存在至少1只可作为对象的水属性表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c31320433.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出发动时的选择提示，提示玩家选择要指定的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 在自己场上选择1只表侧表示水属性怪兽，将其设为效果②的对象。
	local g=Duel.SelectTarget(tp,c31320433.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c31320433.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“指定对象以外的自己场上怪兽不能攻击”的誓约效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的最终处理：为对象怪兽赋予本回合可以直接攻击的效果。
function c31320433.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽可以直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 不能攻击效果的除外判定：若怪兽不是效果②选择的对象（FieldID不同），则该怪兽不能攻击。
function c31320433.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
