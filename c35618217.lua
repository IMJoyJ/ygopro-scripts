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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被效果送去墓地的场合，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
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
	-- 设置效果e3的发动条件为aux.bpcon，即仅在玩家可进入战斗阶段或当前处于战斗阶段时满足发动条件，从而限制③效果只能在主要阶段或战斗阶段中发动。
	e3:SetCondition(aux.bpcon)
	e3:SetOperation(c35618217.actop)
	c:RegisterEffect(e3)
end
-- 定义①的代价筛选函数：从卡组·额外卡组中查找满足条件的「月光」怪兽作为cost，该怪兽需属于「月光」字段、是怪兽卡、不能是本卡已经作为融合素材代用的同名卡，并且可以作为cost送去墓地。
function c35618217.costfilter(c,ec)
	return c:IsSetCard(0xdf) and not c:IsFusionCode(ec:GetFusionCode()) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①的发动代价处理：先检查是否有符合条件的「月光」怪兽，然后提示玩家选择1张，将其以代价形式（REASON_COST）送去墓地，并把送墓怪兽的卡号记录到效果标签，供后续融合素材代用使用。
function c35618217.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost检查阶段：若己方卡组·额外卡组中存在至少1张满足costfilter的卡，则返回true，允许发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c35618217.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c) end
	-- 向玩家发送选卡提示，提示内容为“请选择要送去墓地的卡”，用于选择要送去墓地的「月光」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组·额外卡组中选择1张满足costfilter的「月光」怪兽作为代价。
	local cg=Duel.SelectMatchingCard(tp,c35618217.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c)
	-- 将选中的「月光」怪兽以cost名义（REASON_COST）从卡组·额外卡组送去墓地。
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
-- ①效果处理：若这张卡仍在场上且表侧表示，则给它赋予一个“融合素材代用名”效果——EFFECT_ADD_FUSION_CODE，值为cost中送墓怪兽的卡号，使其本回合作为融合素材时可以当作那只怪兽同名卡，持续到结束阶段，且该效果不会被无效。
function c35618217.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这个回合，把表侧表示的这张卡作为融合素材的场合，可以作为送去墓地的那只怪兽的同名卡来成为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_FUSION_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
end
-- ②效果发动条件：只有当这张卡被“效果”（REASON_EFFECT）送去墓地时才满足条件；被cost或战斗等原因送墓不能发动。
function c35618217.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 定义墓地「融合」的筛选条件：卡号是24094653（「融合」）且能够加入手卡，用于②选对象。
function c35618217.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ②的取对象处理：检查可选对象后，让玩家从自己墓地选择1张「融合」作为对象，并设置操作信息为回手牌（CATEGORY_TOHAND）。
function c35618217.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35618217.thfilter(chkc) end
	-- 发动时合法性检查：确认自己墓地存在至少1张满足thfilter的「融合」卡，若存在则允许发动②。
	if chk==0 then return Duel.IsExistingTarget(c35618217.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选卡提示，提示内容为“请选择要加入手牌的卡”，用于选择墓地的「融合」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张「融合」魔法卡，将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c35618217.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：将选中的1张对象标记为将加入手牌（CATEGORY_TOHAND），用于系统时点和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②的处理：取得对象卡，若对象仍与效果关联，则将其加入持有者手卡。
function c35618217.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（此前选择的墓地「融合」卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③效果处理：创建一个影响对方的场地永续效果，使其在战斗阶段中不能发动效果；持续到回合结束，并仅在战斗阶段（actcon）时生效。
function c35618217.actop(e,tp,eg,ep,ev,re,r,rp)
	-- ③：这张卡被除外的场合才能发动。这个回合，对方在战斗阶段中不能把效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c35618217.actcon)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的“对方不能发动效果”的效果e1注册到游戏中，由当前玩家tp控制，使该效果生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义actcon条件：当前阶段位于PHASE_BATTLE_START到PHASE_BATTLE之间（即战斗阶段中）时返回true，用于限制不能发动效果只在战斗阶段适用。
function c35618217.actcon(e)
	-- 获取当前游戏阶段并保存到变量ph，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
