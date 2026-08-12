--ウォークライ・マムード
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，这张卡可以不用解放作召唤。
-- ②：自己的战士族·地属性怪兽进行战斗的伤害计算后，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
function c84903021.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84903021,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c84903021.tscon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己的战士族·地属性怪兽进行战斗的伤害计算后，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84903021,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCountLimit(1,84903021)
	e2:SetTarget(c84903021.dstg)
	e2:SetOperation(c84903021.dsop)
	c:RegisterEffect(e2)
end
-- 过滤里侧表示怪兽或非战士族怪兽（用于判断场上是否存在非战士族怪兽）
function c84903021.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_WARRIOR)
end
-- 不用解放作召唤的条件判定函数
function c84903021.tscon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定是否为5星以上怪兽、召唤所需最少解放怪兽数量为0，且自己场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己场上没有怪兽，或者自己场上的怪兽全部都是表侧表示的战士族怪兽
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c84903021.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 判定进行战斗的怪兽是否为自己场上的战士族·地属性怪兽
function c84903021.check(c,tp)
	return c and c:IsControler(tp) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果②的发动条件判定、对象选择与效果分类设置
function c84903021.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 在发动条件判定时，检查攻击怪兽或被攻击怪兽是否为自己场上的战士族·地属性怪兽
	if chk==0 then return (c84903021.check(Duel.GetAttacker(),tp) or c84903021.check(Duel.GetAttackTarget(),tp))
		-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
		and Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查自己场上是否存在可以上升攻击力的「战吼」怪兽
		and Duel.IsExistingMatchingCard(c84903021.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤自己场上表侧表示且未被战斗破坏的「战吼」怪兽
function c84903021.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的效果处理，执行破坏魔陷以及后续的「战吼」怪兽攻击力上升处理
function c84903021.dsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片在效果处理时仍符合条件，则将其破坏，并判断是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的攻击力上升处理不与破坏同时进行
		Duel.BreakEffect()
		-- 获取自己场上所有符合条件的「战吼」怪兽
		local ag=Duel.GetMatchingGroup(c84903021.atkfilter,tp,LOCATION_MZONE,0,nil)
		-- 遍历所有符合条件的「战吼」怪兽
		for tc2 in aux.Next(ag) do
			-- 自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			e1:SetValue(200)
			tc2:RegisterEffect(e1)
		end
	end
end
