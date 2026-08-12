--ゾディアックS
-- 效果：
-- ①：自己场上的「十二兽」怪兽的攻击力·守备力上升300。
-- ②：只要这张卡在场地区域存在，对方不能选择除自己场上的攻击力最高的兽战士族怪兽以外的自己的兽战士族怪兽作为攻击对象。
-- ③：1回合1次，自己场上的「十二兽」怪兽被效果破坏的场合，可以作为那1只「十二兽」怪兽的代替而把自己的手卡·场上1只怪兽破坏。
function c675319.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「十二兽」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤自己场上的「十二兽」怪兽作为攻击力上升效果的适用对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf1))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，对方不能选择除自己场上的攻击力最高的兽战士族怪兽以外的自己的兽战士族怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c675319.atlimit)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己场上的「十二兽」怪兽被效果破坏的场合，可以作为那1只「十二兽」怪兽的代替而把自己的手卡·场上1只怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c675319.reptg)
	e5:SetValue(c675319.repval)
	e5:SetOperation(c675319.repop)
	c:RegisterEffect(e5)
end
-- 过滤场上表侧表示、且攻击力比指定值高的兽战士族怪兽
function c675319.atfilter(c,atk)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and c:GetAttack()>atk
end
-- 限制攻击目标函数，若自己场上存在攻击力比该怪兽更高的兽战士族怪兽，则该怪兽不能被选择为攻击对象
function c675319.atlimit(e,c)
	-- 判断该怪兽是否为表侧表示的兽战士族，且自己场上是否存在攻击力比它更高的兽战士族怪兽
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and Duel.IsExistingMatchingCard(c675319.atfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetAttack())
end
-- 过滤自己场上因效果破坏且未处于代破状态的「十二兽」怪兽
function c675319.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0xf1) and c:IsReason(REASON_EFFECT) and c:GetFlagEffect(675319)==0 and not c:IsReason(REASON_REPLACE)
end
-- 过滤自己手卡或场上可以被效果破坏的怪兽（排除已确定被破坏的卡）
function c675319.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsType(TYPE_MONSTER)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的靶向与条件检查函数
function c675319.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足代破条件：自己手卡或场上存在可破坏的怪兽，且当前有符合条件的「十二兽」怪兽将被效果破坏
	if chk==0 then return Duel.IsExistingMatchingCard(c675319.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp)
		and eg:IsExists(c675319.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c675319.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 提示玩家选择要代替其破坏的那1只「十二兽」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		-- 提示玩家选择作为代替而破坏的自己手卡·场上的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择自己手卡或场上1只用于代替破坏的怪兽
		local tg=Duel.SelectMatchingCard(tp,c675319.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的代替破坏怪兽设为效果处理对象
		Duel.SetTargetCard(tg)
		tg:GetFirst():RegisterFlagEffect(675319,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
		tg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 确定代替破坏的适用对象，即被选定保护的那1只「十二兽」怪兽
function c675319.repval(e,c)
	return c==e:GetLabelObject()
end
-- 代替破坏效果的实际执行函数
function c675319.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示此卡，提示发动代替破坏效果
	Duel.Hint(HINT_CARD,0,675319)
	-- 获取选定的作为代替破坏的怪兽
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将作为代替的怪兽因效果代替而破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
