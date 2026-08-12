--極神皇ロキ
-- 效果：
-- 名字带有「极星灵」的调整＋调整以外的怪兽2只以上
-- 1回合1次，自己的战斗阶段中对方把魔法·陷阱卡发动时，可以把那个发动无效并破坏。场上表侧表示存在的这张卡被对方破坏送去墓地的场合，那个回合的结束阶段时可以把自己墓地存在的1只名字带有「极星灵」的调整从游戏中除外，这张卡从墓地特殊召唤。这个效果特殊召唤成功时，可以选择自己墓地存在的1张陷阱卡加入手卡。
function c67098114.initial_effect(c)
	-- 添加同调召唤手续，要求为「极星灵」调整+调整以外的怪兽2只以上
	aux.AddSynchroProcedure(c,c67098114.tfilter,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- 1回合1次，自己的战斗阶段中对方把魔法·陷阱卡发动时，可以把那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67098114,0))  --"魔法陷阱的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c67098114.discon)
	e1:SetTarget(c67098114.distg)
	e1:SetOperation(c67098114.disop)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被对方破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c67098114.regop)
	c:RegisterEffect(e2)
	-- 那个回合的结束阶段时可以把自己墓地存在的1只名字带有「极星灵」的调整从游戏中除外，这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67098114,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c67098114.spcon)
	e3:SetCost(c67098114.spcost)
	e3:SetTarget(c67098114.sptg)
	e3:SetOperation(c67098114.spop)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤成功时，可以选择自己墓地存在的1张陷阱卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67098114,2))  --"墓地的1张陷阱卡加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c67098114.thcon)
	e4:SetTarget(c67098114.thtg)
	e4:SetOperation(c67098114.thop)
	c:RegisterEffect(e4)
end
-- 同调素材过滤条件：名字带有「极星灵」的调整怪兽
function c67098114.tfilter(c)
	return c:IsSetCard(0xa042) or c:IsHasEffect(61777313)
end
-- 无效魔法·陷阱卡发动效果的触发条件
function c67098114.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身未被战斗破坏，且当前是自己的回合
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.GetTurnPlayer()==tp
		-- 检查是对方发动的魔法·陷阱卡，且处于战斗阶段，并且该发动可以被无效
		and ep~=tp and bit.band(Duel.GetCurrentPhase(),0x38)~=0 and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 无效魔法·陷阱卡发动效果的靶向/操作信息设置
function c67098114.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效魔法·陷阱卡发动效果的执行
function c67098114.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该卡的发动，且该卡仍与连锁相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 在场上表侧表示的自身被对方破坏送去墓地时，注册结束阶段特殊召唤的效果标识
function c67098114.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if rp==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(pos,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(67098114,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 特殊召唤效果的触发条件：检查本回合是否注册了被对方破坏送墓的标识
function c67098114.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(67098114)~=0
end
-- 除外Cost过滤条件：自己墓地存在的1只名字带有「极星灵」的调整
function c67098114.cfilter(c)
	return c:IsSetCard(0xa042) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的发动代价（Cost）处理
function c67098114.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可作为Cost除外的「极星灵」调整
	if chk==0 then return Duel.IsExistingMatchingCard(c67098114.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地存在的1只「极星灵」调整
	local g=Duel.SelectMatchingCard(tp,c67098114.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的靶向/操作信息设置
function c67098114.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行
function c67098114.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以自身效果表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 回收陷阱卡效果的触发条件：自身通过自身效果特殊召唤成功
function c67098114.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 回收对象过滤条件：自己墓地存在的1张陷阱卡
function c67098114.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 回收陷阱卡效果的靶向/操作信息设置
function c67098114.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67098114.thfilter(chkc) end
	-- 检查自己墓地是否存在可回收的陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c67098114.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地存在的1张陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c67098114.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收陷阱卡效果的执行
function c67098114.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
