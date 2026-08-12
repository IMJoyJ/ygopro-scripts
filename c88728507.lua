--ヴァンパイア・ソーサラー
-- 效果：
-- ①：这张卡被对方送去墓地的场合才能发动。从卡组把1只暗属性「吸血鬼」怪兽或者1张「吸血鬼」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。这个回合只有1次，自己在5星以上的暗属性「吸血鬼」怪兽召唤的场合需要的解放可以不用。
function c88728507.initial_effect(c)
	-- ①：这张卡被对方送去墓地的场合才能发动。从卡组把1只暗属性「吸血鬼」怪兽或者1张「吸血鬼」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88728507,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c88728507.condition)
	e1:SetTarget(c88728507.target)
	e1:SetOperation(c88728507.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合只有1次，自己在5星以上的暗属性「吸血鬼」怪兽召唤的场合需要的解放可以不用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88728507,1))  --"减少解放数量"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置将墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c88728507.sumop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：检查这张卡是否被对方送去墓地，且送去墓地前由自己控制。
function c88728507.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤卡组中属于「吸血鬼」字段且是魔法·陷阱卡或暗属性怪兽，并且能加入手牌的卡。
function c88728507.filter(c)
	return c:IsSetCard(0x8e) and (c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组中是否存在符合条件的卡，并设置检索并加入手牌的操作信息。
function c88728507.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c88728507.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张满足条件的卡加入手牌，并给对方确认。
function c88728507.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c88728507.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的效果处理：在玩家身上注册一个本回合内仅限1次，召唤特定怪兽时不需要解放的全局效果。
function c88728507.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否尚未注册过该免解放召唤的效果标记。
	if Duel.GetFlagEffect(tp,88728507)==0 then
		-- 这个回合只有1次，自己在5星以上的暗属性「吸血鬼」怪兽召唤的场合需要的解放可以不用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(88728507,2))  --"不解放进行召唤（吸血鬼巫师）"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCountLimit(1)
		e1:SetCondition(c88728507.ntcon)
		e1:SetTarget(c88728507.nttg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将免解放召唤的全局效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
		-- 为玩家注册一个持续到回合结束的标记，用于限制该效果每回合只能适用1次。
		Duel.RegisterFlagEffect(tp,88728507,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 免解放召唤效果的适用条件：检查是否是不需要解放的召唤，且自己场上有可用的怪兽区域。
function c88728507.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查所需的最小解放数量是否为0（即不解放），且自己场上是否有空余的怪兽区域。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 免解放召唤效果的适用对象过滤：等级在5星以上、属于「吸血鬼」字段且是暗属性的怪兽。
function c88728507.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK)
end
