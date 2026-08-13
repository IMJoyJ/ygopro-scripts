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
	-- ①：恐龙族以外的场上的怪兽的攻击力·守备力下降500。
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
	-- ②：1回合1次，恐龙族怪兽召唤·特殊召唤的场合才能发动。在对方场上把1只「侏罗蛋衍生物」（恐龙族·地·1星·攻/守0）守备表示特殊召唤。
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
	-- ③：只要对方场上有衍生物，对方不能把衍生物以外的场上的怪兽作为效果的对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetCondition(c17228908.tgcon)
	e6:SetTarget(c17228908.tglimit)
	-- 设置该『不能成为效果对象』效果的Value为aux.tgoval函数，使该限制只针对对方发动的效果，即不会成为对方的卡的效果对象。
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	-- ④：1回合1次，场上的通常怪兽被战斗·效果破坏的场合，可以作为代替把那个数量的自己的手卡·卡组的恐龙族怪兽破坏。
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
-- atktg：效果①的目标筛选函数，判定怪兽不是恐龙族，只有非恐龙族怪兽才会受到攻击力下降500的影响。
function c17228908.atktg(e,c)
	return not c:IsRace(RACE_DINOSAUR)
end
-- cfilter：判定怪兽是否为表侧表示且为恐龙族，用于检测召唤·特殊召唤成功的怪兽是否为恐龙族。
function c17228908.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- tkcon：效果②的发动条件，召唤成功的怪兽组中存在至少1只表侧表示恐龙族怪兽时满足条件。
function c17228908.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17228908.cfilter,1,nil,tp)
end
-- tktg：效果②发动时的合法检查与处理设定，检查对方怪兽区有空位且自己能将衍生物特殊召唤到对方场上。
function c17228908.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段（chk==0），确认对方场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 同时确认自己能够把「侏罗蛋衍生物」以表侧守备表示、恐龙族·地·1星·攻/守0特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17228909,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DINOSAUR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置该发动连锁的处理信息：包含1次特殊召唤操作，因为衍生物在效果处理时才确定，targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置该发动连锁的处理信息：包含1次衍生物生成操作，衍生物的持有者为自己。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- tkop：效果②处理时，若本卡仍关联且条件满足，则在对方场上生成「侏罗蛋衍生物」并表侧守备表示特殊召唤。
function c17228908.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时先检查失落世界是否仍然与效果关联（即未离场/未失效），并且对方怪兽区仍有空格。
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 再次确认自己仍可将侏罗蛋衍生物特殊召唤到对方场上，满足则继续执行特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17228909,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DINOSAUR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then
		-- 以自己为持有者创建1只编号17228909的「侏罗蛋衍生物」。
		local token=Duel.CreateToken(tp,17228909)
		-- 将生成的衍生物以表侧守备表示特殊召唤到对方（1-tp）的怪兽区。
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- tgcon：效果③的适用条件，通过aux.tkfcon判断对方场上是否存在衍生物。
function c17228908.tgcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方（1-tp）场上是否有衍生物，若有则效果③开始适用。
	return aux.tkfcon(e,1-tp)
end
-- tglimit：效果③的筛选目标，衍生物以外（非TOKEN）的场上的怪兽才会被限制成为效果对象。
function c17228908.tglimit(e,c)
	return not c:IsType(TYPE_TOKEN)
end
-- repfilter：判断被破坏的怪兽是否符合代破条件：表侧表示、通常怪兽、位于怪兽区、且破坏原因为战斗或效果，且尚未列入本次代破对象。
function c17228908.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetFlagEffect(17228908)==0
end
-- desfilter：选择代替破坏的卡的条件：自己手卡·卡组中的恐龙族怪兽，可被效果破坏，且未被确认破坏或战破确定。
function c17228908.desfilter(c,e)
	return c:IsRace(RACE_DINOSAUR) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- reptg：效果④的发动条件与目标选择，统计本次将被破坏的通常怪兽数ct，并检查手卡·卡组是否有足够恐龙族怪兽可代替破坏。
function c17228908.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c17228908.repfilter,nil,tp)
	if chk==0 then return ct>0
		-- 进一步确认自己的手卡·卡组中存在至少ct只符合条件的恐龙族怪兽，否则不能发动代破效果。
		and Duel.IsExistingMatchingCard(c17228908.desfilter,tp,LOCATION_HAND+LOCATION_DECK,0,ct,nil,e) end
	-- 询问失落世界控制者是否发动代替破坏效果，选择“是”才进行后续代替破坏处理。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 向控制者发送选卡提示，提示文字为“请选择要代替破坏的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己的手卡·卡组中选择恰好ct张符合条件的恐龙族怪兽，作为代替破坏的卡。
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
-- repval：代破效果的Value函数，对每只将被破坏的怪兽调用repfilter，判断其是否为可代破的通常怪兽。
function c17228908.repval(e,c)
	return c17228908.repfilter(c,e:GetHandlerPlayer())
end
-- repop：代替破坏处理：提示失落世界的卡片动画，取出之前选择的恐龙族怪兽组，清除其破坏确认状态，然后将其破坏。
function c17228908.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示失落世界的卡片发动/效果动画，向双方提示本次代替破坏由失落世界执行。
	Duel.Hint(HINT_CARD,0,17228908)
	local tg=e:GetLabelObject()
	local tc=tg:GetFirst()
	while tc do
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
		tc=tg:GetNext()
	end
	-- 将选择的恐龙族怪兽以“效果破坏+代替破坏”的理由破坏，完成代替破坏的最终处理。
	Duel.Destroy(tg,REASON_EFFECT+REASON_REPLACE)
end
