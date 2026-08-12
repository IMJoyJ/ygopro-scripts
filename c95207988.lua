--地縛共振
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的场上的怪兽被效果破坏的场合，以那之内的1只为对象才能发动。双方受到那只怪兽的攻击力一半数值的伤害。
-- ②：从额外卡组特殊召唤的自己的暗属性同调怪兽被选择作为攻击对象时，以场上1张卡为对象才能发动。那张卡破坏。
function c95207988.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从额外卡组特殊召唤的场上的怪兽被效果破坏的场合，以那之内的1只为对象才能发动。双方受到那只怪兽的攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95207988,0))  --"双方受到伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,95207988)
	e2:SetCondition(c95207988.damcon)
	e2:SetTarget(c95207988.damtg)
	e2:SetOperation(c95207988.damop)
	c:RegisterEffect(e2)
	-- ②：从额外卡组特殊召唤的自己的暗属性同调怪兽被选择作为攻击对象时，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95207988,1))  --"选择卡破坏"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,95207988+1)
	e3:SetCondition(c95207988.descon)
	e3:SetTarget(c95207988.destg)
	e3:SetOperation(c95207988.desop)
	c:RegisterEffect(e3)
end
-- 过滤被效果破坏的、从额外卡组特殊召唤的场上怪兽（非衍生物）
function c95207988.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonLocation(LOCATION_EXTRA)
		and not c:IsType(TYPE_TOKEN)
		and c:IsReason(REASON_EFFECT)
end
-- 检查是否有满足条件的怪兽被效果破坏，作为效果①的发动条件
function c95207988.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95207988.cfilter,1,nil,tp)
end
-- 过滤可以成为效果对象且攻击力不为0的怪兽
function c95207988.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and not c:IsAttack(0)
end
-- 效果①的发动准备，筛选符合条件的对象并进行选择，设置伤害操作信息
function c95207988.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c95207988.cfilter,nil,tp):Filter(c95207988.tgfilter,nil,e)
	if chkc then return mg:IsContains(chkc) end
	if chk==0 then return mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选择的怪兽设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示该效果包含对双方玩家造成伤害的处理
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 效果①的效果处理，使双方玩家受到作为对象的怪兽攻击力一半数值的效果伤害
function c95207988.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 对回合玩家造成该怪兽攻击力一半数值的效果伤害（分步处理）
		Duel.Damage(tp,tc:GetAttack()/2,REASON_EFFECT,true)
		-- 对对方玩家造成该怪兽攻击力一半数值的效果伤害（分步处理）
		Duel.Damage(1-tp,tc:GetAttack()/2,REASON_EFFECT,true)
		-- 完成分步伤害处理，触发相关的伤害/回复时点
		Duel.RDComplete()
	end
end
-- 检查被选择作为攻击对象的怪兽是否为自己场上表侧表示的、从额外卡组特殊召唤的暗属性同调怪兽，作为效果②的发动条件
function c95207988.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_DARK)
		and tc:IsType(TYPE_SYNCHRO) and tc:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果②的发动准备，确认场上存在可选择的卡，并选择场上1张卡作为破坏对象，设置破坏操作信息
function c95207988.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示该效果包含破坏所选卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理，将作为对象的卡破坏
function c95207988.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的破坏对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在效果处理时仍存在于场上，则将其因效果破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
