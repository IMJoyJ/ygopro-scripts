--アルカナフォースEX－THE DARK RULER
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的3只怪兽送去墓地的场合才能特殊召唤。这张卡特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：这张卡在战斗阶段中可以作2次攻击。进行这个效果适用的第2次战斗的场合，这张卡在战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
-- ●里：这张卡被破坏的场合，场上的卡全部破坏。
local s,id,o=GetID()
-- 注册卡片效果：召唤限制、特殊召唤规则、投掷硬币、表侧2次攻击、表侧战斗阶段结束变守备及不能改变表示形式、里侧被破坏时全场破坏。
function c69831560.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己场上存在的3只怪兽送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c69831560.spcon)
	e1:SetTarget(c69831560.sptg)
	e1:SetOperation(c69831560.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 注册特殊召唤成功时进行1次投掷硬币的效果。
	aux.EnableArcanaCoin(c,EVENT_SPSUMMON_SUCCESS)
	-- ●表：这张卡在战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(c69831560.macon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 进行这个效果适用的第2次战斗的场合，这张卡在战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetCountLimit(1)
	e4:SetCondition(c69831560.poscon)
	e4:SetOperation(c69831560.posop)
	c:RegisterEffect(e4)
	-- ●里：这张卡被破坏的场合
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetCondition(c69831560.descon1)
	e5:SetOperation(c69831560.desop1)
	c:RegisterEffect(e5)
	-- 场上的卡全部破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(c69831560.descon2)
	e6:SetOperation(c69831560.desop2)
	c:RegisterEffect(e6)
end
-- 过滤可以作为特殊召唤Cost送去墓地的怪兽。
function c69831560.spfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 检查自己场上是否存在3只可以送去墓地的怪兽作为特殊召唤的条件。
function c69831560.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可以作为Cost送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(c69831560.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否能选出3只怪兽，且在送去墓地后有足够的怪兽区域空位。
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤规则的准备操作，让玩家选择3只送去墓地的怪兽。
function c69831560.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可以作为Cost送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(c69831560.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择3只满足怪兽区域空位检查的怪兽。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作，将选中的怪兽送去墓地。
function c69831560.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的Cost送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查硬币投掷结果是否为表侧（正面）。
function c69831560.macon(e)
	return e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 检查硬币投掷结果是否为表侧，且这张卡在当前战斗阶段是否进行了2次以上的攻击。
function c69831560.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:GetAttackAnnouncedCount()>=2
end
-- 将这张卡变成守备表示，并施加直到下次自己回合结束时不能改变表示形式的效果。
function c69831560.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡转为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合结束时这张卡不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否因被破坏而准备离场，且硬币投掷结果为里侧（反面）。
function c69831560.descon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 在这张卡因破坏离场前，给自身注册一个临时标记，用于在离场后触发全场破坏效果。
function c69831560.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查这张卡是否带有因破坏离场而注册的临时标记。
function c69831560.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 破坏场上的所有卡，并重置临时标记。
function c69831560.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上的所有卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 显式展示这张卡发动的动画提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 因效果破坏场上的所有卡。
	Duel.Destroy(g,REASON_EFFECT)
	c:ResetFlagEffect(id)
end
