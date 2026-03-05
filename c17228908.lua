--ロストワールド
-- 效果：
-- ①：恐龙族以外的场上的怪兽的攻击力·守备力下降500。
-- ②：1回合1次，恐龙族怪兽召唤·特殊召唤的场合才能发动。在对方场上把1只「侏罗蛋衍生物」（恐龙族·地·1星·攻/守0）守备表示特殊召唤。
-- ③：只要对方场上有衍生物，对方不能把衍生物以外的场上的怪兽作为效果的对象。
-- ④：1回合1次，场上的通常怪兽被战斗·效果破坏的场合，可以作为代替把那个数量的自己的手卡·卡组的恐龙族怪兽破坏。
function c17228908.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：恐龙族以外的场上的怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c17228908.atktg)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 效果原文内容：②：1回合1次，恐龙族怪兽召唤·特殊召唤的场合才能发动。在对方场上把1只「侏罗蛋衍生物」（恐龙族·地·1星·攻/守0）守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17228908,0))  --"特殊召唤衍生物"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(c17228908.tkcon)
	e4:SetTarget(c17228908.tktg)
	e4:SetOperation(c17228908.tkop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	-- 效果原文内容：③：只要对方场上有衍生物，对方不能把衍生物以外的场上的怪兽作为效果的对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetCondition(c17228908.tgcon)
	e6:SetTarget(c17228908.tglimit)
	-- 规则层面操作：设置效果值为aux.tgoval函数，用于判断目标是否不能成为效果对象。
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	-- 效果原文内容：④：1回合1次，场上的通常怪兽被战斗·效果破坏的场合，可以作为代替把那个数量的自己的手卡·卡组的恐龙族怪兽破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(c17228908.reptg)
	e7:SetValue(c17228908.repval)
	e7:SetOperation(c17228908.repop)
	c:RegisterEffect(e7)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e7:SetLabelObject(g)
end
-- 规则层面操作：判断目标怪兽是否不是恐龙族。
function c17228908.atktg(e,c)
	return not c:IsRace(RACE_DINOSAUR)
end
-- 规则层面操作：过滤出场上表侧表示的恐龙族怪兽。
function c17228908.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 规则层面操作：判断是否有恐龙族怪兽被召唤或特殊召唤成功。
function c17228908.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17228908.cfilter,1,nil,tp)
end
-- 规则层面操作：判断是否满足特殊召唤衍生物的条件。
function c17228908.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断对方场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断是否可以特殊召唤侏罗蛋衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17228909,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DINOSAUR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) end
	-- 规则层面操作：设置操作信息为特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 规则层面操作：设置操作信息为召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 规则层面操作：执行特殊召唤侏罗蛋衍生物的效果。
function c17228908.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场地卡是否有效。
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断是否可以特殊召唤侏罗蛋衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17228909,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DINOSAUR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then
		-- 规则层面操作：创建侏罗蛋衍生物。
		local token=Duel.CreateToken(tp,17228909)
		-- 规则层面操作：将侏罗蛋衍生物特殊召唤到对方场上。
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 规则层面操作：判断对方场上是否存在衍生物。
function c17228908.tgcon(e)
	local tp=e:GetHandlerPlayer()
	-- 规则层面操作：调用aux.tkfcon函数判断对方场上是否存在衍生物。
	return aux.tkfcon(e,1-tp)
end
-- 规则层面操作：判断目标是否不是衍生物。
function c17228908.tglimit(e,c)
	return not c:IsType(TYPE_TOKEN)
end
-- 规则层面操作：过滤出场上被破坏的通常怪兽。
function c17228908.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetFlagEffect(17228908)==0
end
-- 规则层面操作：过滤出可以被代替破坏的恐龙族怪兽。
function c17228908.desfilter(c,e)
	return c:IsRace(RACE_DINOSAUR) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 规则层面操作：判断是否满足代替破坏的条件。
function c17228908.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c17228908.repfilter,nil,tp)
	if chk==0 then return ct>0
		-- 规则层面操作：判断是否有足够的恐龙族怪兽可以代替破坏。
		and Duel.IsExistingMatchingCard(c17228908.desfilter,tp,LOCATION_HAND+LOCATION_DECK,0,ct,nil,e) end
	-- 规则层面操作：询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 规则层面操作：提示玩家选择代替破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 规则层面操作：选择代替破坏的恐龙族怪兽。
		local tg=Duel.SelectMatchingCard(tp,c17228908.desfilter,tp,LOCATION_HAND+LOCATION_DECK,0,ct,ct,nil,e)
		local g=e:GetLabelObject()
		g:Clear()
		local tc=tg:GetFirst()
		while tc do
			tc:RegisterFlagEffect(17228908,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
			tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
			g:AddCard(tc)
			tc=tg:GetNext()
		end
		return true
	else return false end
end
-- 规则层面操作：设置代替破坏的判断函数。
function c17228908.repval(e,c)
	return c17228908.repfilter(c,e:GetHandlerPlayer())
end
-- 规则层面操作：执行代替破坏的效果。
function c17228908.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示发动了代替破坏效果。
	Duel.Hint(HINT_CARD,0,17228908)
	local tg=e:GetLabelObject()
	local tc=tg:GetFirst()
	while tc do
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
		tc=tg:GetNext()
	end
	-- 规则层面操作：将选择的卡破坏。
	Duel.Destroy(tg,REASON_EFFECT+REASON_REPLACE)
end
