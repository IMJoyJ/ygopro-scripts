--サンセット・ビート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧守备表示的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己场上的反转怪兽反转的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。给与对方那只怪兽的等级×200伤害。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动条件和两个触发效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧守备表示的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：自己场上的反转怪兽反转的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。给与对方那只怪兽的等级×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 判断是否满足破坏效果的触发条件：场上是否有自己表侧表示变为里侧表示的怪兽
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 判断是否满足破坏效果的触发条件：场上是否有自己表侧表示变为里侧表示的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置破坏效果的目标选择逻辑：选择场上1张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足破坏效果的发动条件：场上是否存在可破坏的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果：将目标卡片破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足伤害效果的触发条件：场上是否有自己反转表示变为正面表示的反转怪兽
function s.cfilter2(c,tp,e)
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_FLIP) and c:IsCanBeEffectTarget(e)
end
-- 判断是否满足伤害效果的触发条件：场上是否有自己反转表示变为正面表示的反转怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp,e)
end
-- 设置伤害效果的目标选择逻辑：选择符合条件的反转怪兽作为伤害对象
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsPreviousControler(tp)
		and chkc:IsPreviousLocation(LOCATION_MZONE) and s.cfilter2(chkc,tp,e) end
	local g=eg:Filter(s.cfilter2,nil,tp,e)
	-- 检查是否满足伤害效果的发动条件：是否有可选择的反转怪兽且场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE) and #g>0 end
	-- 提示玩家选择伤害效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	-- 设置伤害效果的目标卡片
	Duel.SetTargetCard(tc)
	e:SetLabelObject(tc)
	-- 设置伤害效果的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetLevel()*200)
end
-- 执行伤害效果：对目标怪兽造成其等级×200的伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToEffect(e) or not tc:IsPosition(POS_FACEUP) or not tc:IsType(TYPE_MONSTER) then return end
	-- 对对方玩家造成目标怪兽等级×200的伤害
	Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
end
