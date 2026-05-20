--双頭竜キング・レックス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以持有比自己场上的恐龙族怪兽的攻击力合计低的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤规则、召唤成功时的诱发效果以及特殊召唤成功时的诱发效果
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合，以持有比自己场上的恐龙族怪兽的攻击力合计低的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 自身特殊召唤规则的条件判定函数，检查怪兽区域是否有空位且自己场上没有怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己场上是否有可用的怪兽区域空格，且自己场上的怪兽数量为0
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤出自己场上表侧表示的恐龙族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 过滤出场上表侧表示且攻击力低于指定数值（自己场上恐龙族怪兽攻击力合计）的怪兽
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 效果②的发动准备与目标选择判定，计算自己场上恐龙族怪兽的攻击力合计，并确认场上是否存在符合条件的可选择对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取并计算自己场上所有表侧表示恐龙族怪兽的攻击力合计值
	local atk=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,atk) end
	if chk==0 then return atk>0
		-- 判定场上是否存在至少1只可以成为效果对象、且攻击力低于该合计值的表侧表示怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只符合攻击力条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁处理中的操作信息，表明该效果的处理为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②的实际处理函数，获取对象怪兽并将其破坏
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
