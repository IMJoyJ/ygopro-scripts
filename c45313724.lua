--煉獄の釜
-- 效果：
-- ①：自己场上的「永火」怪兽或者龙族·暗属性·8星的同调怪兽被对方的效果破坏的场合，可以作为代替把自己墓地1张「永火」卡除外。
-- ②：自己手卡不是0张的场合，这张卡送去墓地。
function c45313724.initial_effect(c)
	-- 设置全局标记，允许不入连锁的送墓检查
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 自己场上的「永火」怪兽或者龙族·暗属性·8星的同调怪兽被对方的效果破坏的场合，可以作为代替把自己墓地1张「永火」卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c45313724.desreptg)
	e1:SetValue(c45313724.desrepval)
	c:RegisterEffect(e1)
	-- 自己手卡不是0张的场合，这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SELF_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c45313724.sdcon)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否满足代替破坏的条件，包括怪兽为正面表示、控制者为指定玩家、位置在怪兽区、为「永火」卡或龙族·暗属性·8星的同调怪兽、被对方效果破坏且不是代替破坏、破坏玩家为对方
function c45313724.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsSetCard(0xb) or c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(8) and c:IsType(TYPE_SYNCHRO))
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp
end
-- 过滤函数，用于检索满足条件的「永火」卡，要求为「永火」卡且可以除外
function c45313724.desfilter(c)
	return c:IsSetCard(0xb) and c:IsAbleToRemove()
end
-- 判断是否满足代替破坏的触发条件，检查是否有满足条件的怪兽被破坏且自己墓地有「永火」卡
function c45313724.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c45313724.repfilter,1,nil,tp)
		-- 检查自己墓地是否存在满足条件的「永火」卡
		and Duel.IsExistingMatchingCard(c45313724.desfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择1张满足条件的「永火」卡
		local g=Duel.SelectMatchingCard(tp,c45313724.desfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的卡以正面表示形式除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 设置代替破坏的效果值，返回是否满足代替破坏条件
function c45313724.desrepval(e,c)
	return c45313724.repfilter(c,e:GetHandlerPlayer())
end
-- 判断自己手牌数量是否不为0
function c45313724.sdcon(e)
	-- 返回自己手牌数量是否不为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)~=0
end
