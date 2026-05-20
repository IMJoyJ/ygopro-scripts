--虹天気アルシエル
-- 效果：
-- 「天气」怪兽3只
-- ①：这张卡所连接区的「天气」效果怪兽得到以下效果。
-- ●魔法·陷阱·怪兽的效果发动时，把这张卡除外才能发动。那个发动无效并破坏。
-- ②：对方把怪兽特殊召唤之际，把连接召唤的这张卡送去墓地才能发动。那次特殊召唤无效，那些怪兽破坏。
-- ③：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c54178659.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要3只「天气」怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x109),3,3)
	-- ②：对方把怪兽特殊召唤之际，把连接召唤的这张卡送去墓地才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54178659,0))  --"特殊召唤无效并破坏"
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c54178659.discon)
	e1:SetCost(c54178659.discost)
	e1:SetTarget(c54178659.distg)
	e1:SetOperation(c54178659.disop)
	c:RegisterEffect(e1)
	-- ③：场上的这张卡为让「天气」卡的效果发动而被除外的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c54178659.spreg)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54178659,1))  --"除外的这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(c54178659.spcon)
	e3:SetTarget(c54178659.sptg)
	e3:SetOperation(c54178659.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ●魔法·陷阱·怪兽的效果发动时，把这张卡除外才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54178659,2))  --"发动无效并破坏（虹天气 彩虹）"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c54178659.discon2)
	-- 设置发动成本为将这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c54178659.distg2)
	e4:SetOperation(c54178659.disop2)
	-- ①：这张卡所连接区的「天气」效果怪兽得到以下效果。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c54178659.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 无效特殊召唤效果的发动条件判定
function c54178659.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方在连锁0进行的特殊召唤，且自身是连接召唤的卡
	return tp~=ep and Duel.GetCurrentChain()==0 and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 无效特殊召唤效果的发动成本判定与执行
function c54178659.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动成本
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 无效特殊召唤效果的发动目标判定与操作信息设置
function c54178659.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息为无效特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置连锁操作信息为破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 无效特殊召唤效果的执行函数
function c54178659.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使特殊召唤无效
	Duel.NegateSummon(eg)
	-- 因效果破坏那些怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 记录自身因「天气」卡的效果发动而被除外的状态
function c54178659.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 将效果的Label设置为下个回合的回合数
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(54178659,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 特殊召唤效果的发动条件判定
function c54178659.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为被除外时的下个回合，且自身带有对应的标记
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(54178659)>0
end
-- 特殊召唤效果的发动目标判定与操作信息设置
function c54178659.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判定己方主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(54178659)
end
-- 特殊召唤效果的执行函数
function c54178659.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤得到效果的怪兽：自身所连接区的「天气」效果怪兽
function c54178659.eftg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109) and lg:IsContains(c)
end
-- 无效发动效果的发动条件判定
function c54178659.discon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自身未被战斗破坏，且该连锁的发动可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 无效发动效果的发动目标判定与操作信息设置
function c54178659.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息为无效该效果的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效发动效果的执行函数
function c54178659.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该发动，且该卡在连锁中关系仍成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
