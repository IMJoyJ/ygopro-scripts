--極神聖帝オーディン
-- 效果：
-- 「极星天」调整＋调整以外的怪兽2只以上
-- ①：1回合1次，自己主要阶段才能发动。这张卡直到回合结束时不受魔法·陷阱卡的效果影响。
-- ②：场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段，从自己墓地把1只「极星天」调整除外才能发动。这张卡从墓地特殊召唤。
-- ③：这张卡的②的效果特殊召唤成功时才能发动。自己从卡组抽1张。
function c93483212.initial_effect(c)
	-- 为这张卡添加同调召唤手续，需要以「极星天」调整怪兽为素材，以及2只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,c93483212.tfilter,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。这张卡直到回合结束时不受魔法·陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93483212,0))  --"不受魔法·陷阱卡的影响"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c93483212.imop)
	c:RegisterEffect(e1)
	-- ②：场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段，从自己墓地把1只「极星天」调整除外才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c93483212.regop)
	c:RegisterEffect(e2)
	-- ②：场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段，从自己墓地把1只「极星天」调整除外才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93483212,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c93483212.spcon)
	e3:SetCost(c93483212.spcost)
	e3:SetTarget(c93483212.sptg)
	e3:SetOperation(c93483212.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡的②的效果特殊召唤成功时才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93483212,2))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c93483212.drcon)
	e4:SetTarget(c93483212.drtg)
	e4:SetOperation(c93483212.drop)
	c:RegisterEffect(e4)
end
-- 过滤满足「极星天」字段或具有特定代用效果的同调素材调整怪兽
function c93483212.tfilter(c)
	return c:IsSetCard(0x3042) or c:IsHasEffect(61777313)
end
-- 效果①的发动处理：为这张卡添加直到回合结束时不受魔法·陷阱卡效果影响的抗性
function c93483212.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡直到回合结束时不受魔法·陷阱卡的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c93483212.imfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤魔法和陷阱卡的效果，用于抗性判断
function c93483212.imfilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 检查这张卡是否在场上表侧表示被对方破坏并送去墓地，若是则在回合结束前为自身注册一个Flag（用于满足特殊召唤的条件）
function c93483212.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if rp==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(pos,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(93483212,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 检查自身是否在被对方破坏送去墓地的回合，即是否存在对应的Flag
function c93483212.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(93483212)~=0
end
-- 过滤自己墓地中可以作为发动成本除外的「极星天」调整怪兽
function c93483212.cfilter(c)
	return c:IsSetCard(0x3042) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本：从自己墓地选择1只「极星天」调整怪兽除外
function c93483212.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的「极星天」调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93483212.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「极星天」调整怪兽
	local g=Duel.SelectMatchingCard(tp,c93483212.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动的成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备：检查怪兽区域是否有空位、自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c93483212.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：如果自身仍存在于墓地，则将自身特殊召唤
function c93483212.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤，并标记召唤动作为自身效果特殊召唤
		Duel.SpecialSummon(e:GetHandler(),SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件：检查自身是否是通过自身效果（②的效果）特殊召唤成功
function c93483212.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果③的发动准备：检查玩家是否可以抽卡，并设置抽卡的目标玩家、张数及操作信息
function c93483212.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数（抽卡张数）设置为1
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息，表示自己将从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的效果处理：获取目标玩家和抽卡张数，执行抽卡
function c93483212.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
