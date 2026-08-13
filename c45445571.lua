--死霊公爵
-- 效果：
-- 恶魔族·不死族怪兽×2
-- 这张卡的控制者在每次自己准备阶段支付500基本分或把这张卡破坏。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：自己主要阶段才能发动。进行1只怪兽的召唤。
-- ③：把墓地的这张卡除外，以自己墓地1只4星以上的恶魔族·不死族怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册并添加该卡全部效果的入口函数：融合召唤手续、召唤限制解除、①战斗破坏耐性、②追加召唤效果、③墓地除外回收效果，以及准备阶段支付500基本分或破坏自身的维持效果。
function s.initial_effect(c)
	-- 为这张卡登记融合召唤手续：以2只满足s.ffilter条件的怪兽（恶魔族或不死族）作为融合素材；最后一个true为API的insf标记。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：自己主要阶段才能发动。进行1只怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。③：把墓地的这张卡除外，以自己墓地1只4星以上的恶魔族·不死族怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	-- 设置③效果的发动COST：把墓地中的这张卡自身除外（aux.bfgcost会先检查能否除外并在发动时执行除外）。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 这张卡的控制者在每次自己准备阶段支付500基本分或把这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.mtcon)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
-- 融合素材筛选条件：怪兽属于恶魔族或不死族即满足条件。
function s.ffilter(c)
	return c:IsRace(RACE_FIEND+RACE_ZOMBIE)
end
-- 选择可以进行通常召唤的怪兽：c:IsSummonable(true,nil)用于检查该怪兽在当前规则下是否能够进行通常召唤（true表示不检查本回合通常召唤次数限制）。
function s.filter(c)
	return c:IsSummonable(true,nil)
end
-- ②召唤效果的发动条件与连锁信息：发动时检查自己手牌/场上是否存在可通常召唤的怪兽，并设置本次效果进行1只怪兽召唤的操作信息。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段确认自己手牌/场上存在至少1只满足s.filter的可召唤怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，向系统预告本效果为CATEGORY_SUMMON且将处理1只怪兽的召唤，供后续时点/对应效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 执行②的召唤处理：提示玩家选择要召唤的怪兽，从自己手牌/场上选1只，然后以忽略通常召唤次数限制的方式执行通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示“请选择要召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从自己手牌/场上选出1只满足s.filter的怪兽，作为本效果要通常召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 对选中的怪兽执行通常召唤，ignore_count=true表示忽略本回合的通常召唤次数限制。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 维持效果的触发条件判定：在准备阶段且当前回合玩家是这张卡的控制者时才处理维持COST。
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为这张卡的控制者tp，从而只在己方准备阶段触发维持效果。
	return Duel.GetTurnPlayer()==tp
end
-- 执行准备阶段维持处理：控制者能支付500基本分且选择支付时支付500；否则以COST破坏这张卡。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 先检查控制者能否支付500基本分，并用选择对话框询问是否支付；若不能支付或选择否，则进入破坏自身分支。
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否支付基本分？"
		-- 控制者支付500基本分作为维持代价。
		Duel.PayLPCost(tp,500)
	else
		-- 当不支付或不能支付维持代价时，以REASON_COST破坏这张卡。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- ③回收效果的筛选条件：对象必须是4星以上、恶魔族或不死族、且能够加入手卡的墓地怪兽。
function s.thfilter(c)
	return c:IsRace(RACE_FIEND+RACE_ZOMBIE) and c:IsLevelAbove(4) and c:IsAbleToHand()
end
-- ③效果的发动判定：确认自己墓地存在可取的满足条件的对象后，选择1只对象卡，设置其加入手卡的操作信息，并提示“请选择要加入手卡的卡”。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 在发动检查阶段确认自己墓地存在至少1只满足s.thfilter且能被取为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示“请选择要加入手卡的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只满足s.thfilter的怪兽作为效果对象，自动登记为当前连锁的取对象，并排除这张卡自身。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息，向系统预告本次效果会将选中的1张卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行③回收效果：取出对象卡，若对象仍与效果关联，则将其加入持有者手卡，并向对方玩家展示该卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时本连锁登记的对象卡（因③效果只取1个对象，所以直接取第一张目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把对象卡加入其持有者的手卡（nil表示返回持有者手卡），处理原因标记为EFFECT。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认（展示）那张加入手卡的怪兽，使双方都知道回收的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
