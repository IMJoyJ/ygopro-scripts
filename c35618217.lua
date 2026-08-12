--月光彩雛
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，从卡组·额外卡组把1只「月光」怪兽送去墓地才能发动。这个回合，把表侧表示的这张卡作为融合素材的场合，可以作为送去墓地的那只怪兽的同名卡来成为融合素材。
-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
-- ③：这张卡被除外的场合才能发动。这个回合，对方在战斗阶段中不能把效果发动。
function c35618217.initial_effect(c)
	-- ①：1回合1次，从卡组·额外卡组把1只「月光」怪兽送去墓地才能发动。这个回合，把表侧表示的这张卡作为融合素材的场合，可以作为送去墓地的那只怪兽的同名卡来成为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35618217,0))  --"代替素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c35618217.cost)
	e1:SetOperation(c35618217.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35618217,1))  --"墓地「融合」加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,35618217)
	e2:SetCondition(c35618217.thcon)
	e2:SetTarget(c35618217.thtg)
	e2:SetOperation(c35618217.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合才能发动。这个回合，对方在战斗阶段中不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35618217,2))  --"对方在战斗阶段中不能把效果发动"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	-- 判断当前是否处于可以进行战斗相关操作的时点或阶段。
	e3:SetCondition(aux.bpcon)
	e3:SetOperation(c35618217.actop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「月光」怪兽作为送去墓地的代价。
function c35618217.costfilter(c,ec)
	return c:IsSetCard(0xdf) and not c:IsFusionCode(ec:GetFusionCode()) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的处理函数，用于选择并送去墓地的「月光」怪兽。
function c35618217.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件，即是否存在满足条件的「月光」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35618217.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「月光」怪兽并将其送去墓地。
	local cg=Duel.SelectMatchingCard(tp,c35618217.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c)
	-- 将选择的卡送去墓地作为发动效果的代价。
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
-- 效果发动后的处理函数，用于设置融合素材的识别码。
function c35618217.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 设置融合素材时可以当作指定卡名的同名卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_FUSION_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
end
-- 判断该卡是否因效果被送去墓地。
function c35618217.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数，用于筛选墓地中的「融合」卡。
function c35618217.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于选择并加入手牌的「融合」卡。
function c35618217.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35618217.thfilter(chkc) end
	-- 检查是否满足发动条件，即是否存在满足条件的「融合」卡。
	if chk==0 then return Duel.IsExistingTarget(c35618217.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「融合」卡。
	local g=Duel.SelectTarget(tp,c35618217.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示要将卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动后的处理函数，用于将卡加入手牌。
function c35618217.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果发动后的处理函数，用于设置对方在战斗阶段不能发动效果。
function c35618217.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册一个使对方不能发动效果的永续效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c35618217.actcon)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到指定玩家的全局环境。
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前是否处于战斗阶段。
function c35618217.actcon(e)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
