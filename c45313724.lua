--煉獄の釜
-- 效果：
-- ①：自己场上的「永火」怪兽或者龙族·暗属性·8星的同调怪兽被对方的效果破坏的场合，可以作为代替把自己墓地1张「永火」卡除外。
-- ②：自己手卡不是0张的场合，这张卡送去墓地。
function c45313724.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_SELF_TOGRAVE，使本卡②的EFFECT_SELF_TOGRAVE效果（不入连锁的自我送墓）能被引擎正确检测和处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「永火」怪兽或者龙族·暗属性·8星的同调怪兽被对方的效果破坏的场合，可以作为代替把自己墓地1张「永火」卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c45313724.desreptg)
	e1:SetValue(c45313724.desrepval)
	c:RegisterEffect(e1)
	-- ②：自己手卡不是0张的场合，这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SELF_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c45313724.sdcon)
	c:RegisterEffect(e2)
end
-- 判定某只怪兽是否满足被对方效果破坏的代替条件：它必须表侧表示且在自己怪兽区，并且是「永火」怪兽，或者是龙族·暗属性·8星的同调怪兽；同时其被破坏的原因必须是对方的效果、且不是由代替破坏造成，破坏的发动者也是对方。
function c45313724.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsSetCard(0xb) or c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(8) and c:IsType(TYPE_SYNCHRO))
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp
end
-- 筛选墓地中可以作为代替除外的「永火」卡：属于「永火」系列且能够被除外。
function c45313724.desfilter(c)
	return c:IsSetCard(0xb) and c:IsAbleToRemove()
end
-- 代替破坏效果的发动条件确认：场上存在满足被对方效果破坏条件的怪兽，并且自己墓地有至少1张「永火」卡可用于代替除外。
function c45313724.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c45313724.repfilter,1,nil,tp)
		-- 同时检查自己墓地是否存在至少1张满足desfilter（属于「永火」且可除外）的卡，作为发动代替破坏的代价条件。
		and Duel.IsExistingMatchingCard(c45313724.desfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 让玩家选择是否发动这张卡的代替破坏效果，确认后进入支付代价的处理。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示选择提示消息“请选择要代替破坏的卡”，引导玩家选择要除外的「永火」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己墓地选择1张满足desfilter的「永火」卡，作为代替破坏而要除外的卡。
		local g=Duel.SelectMatchingCard(tp,c45313724.desfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的「永火」卡以表侧表示除外，代替怪兽被破坏；除外原因标记为效果和代替。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 作为EFFECT_DESTROY_REPLACE的Value回调：在破坏处理时，用repfilter判断当前即将被破坏的怪兽是否适用本代替效果。
function c45313724.desrepval(e,c)
	return c45313724.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的自我送去墓地条件函数：当自己手牌数不为0时，这张卡要被送去墓地。
function c45313724.sdcon(e)
	-- 返回自己手牌数量是否不等于0：若手牌不为0则条件成立，这张卡送去墓地。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)~=0
end
