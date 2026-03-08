--死霊公爵
-- 效果：
-- 恶魔族·不死族怪兽×2
-- 这张卡的控制者在每次自己准备阶段支付500基本分或把这张卡破坏。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：自己主要阶段才能发动。进行1只怪兽的召唤。
-- ③：把墓地的这张卡除外，以自己墓地1只4星以上的恶魔族·不死族怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用2个满足s.ffilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	c:EnableReviveLimit()
	-- 效果①：这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果②：自己主要阶段才能发动。进行1只怪兽的召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- 效果③：把墓地的这张卡除外，以自己墓地1只4星以上的恶魔族·不死族怪兽为对象才能发动。那只怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	-- 设置效果③的发动费用为将此卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 设置准备阶段时触发的效果，用于支付LP或破坏此卡
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
-- 过滤函数，用于筛选恶魔族和不死族怪兽
function s.ffilter(c)
	return c:IsRace(RACE_FIEND+RACE_ZOMBIE)
end
-- 过滤函数，用于筛选可通常召唤的怪兽
function s.filter(c)
	return c:IsSummonable(true,nil)
end
-- 效果②的发动条件判断函数，检查是否有可召唤的怪兽
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果②的发动信息为召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的发动处理函数，选择并召唤怪兽
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 准备阶段触发条件判断函数，判断是否为当前回合玩家
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段触发处理函数，询问是否支付LP或破坏此卡
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能支付500LP并询问玩家选择
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否支付基本分？"
		-- 支付500LP
		Duel.PayLPCost(tp,500)
	else
		-- 破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 过滤函数，用于筛选恶魔族或不死族4星以上的怪兽
function s.thfilter(c)
	return c:IsRace(RACE_FIEND+RACE_ZOMBIE) and c:IsLevelAbove(4) and c:IsAbleToHand()
end
-- 效果③的发动条件判断函数，检查是否有满足条件的墓地怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果③的发动信息为将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的发动处理函数，将目标怪兽加入手牌并确认其存在
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方能看到该怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
