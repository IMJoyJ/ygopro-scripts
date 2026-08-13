--ゴーストリックの魔女
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。
function c27491571.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c27491571.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27491571,0))  --"变成里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c27491571.postg)
	e2:SetOperation(c27491571.posop)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27491571,1))  --"选择对方场上怪兽变成里侧守备表示"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c27491571.postg2)
	e3:SetOperation(c27491571.posop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定怪兽是否为表侧表示且卡名含有「鬼计」字段。
function c27491571.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤条件判断：当自己场上不存在表侧表示的名字带有「鬼计」的怪兽时，e1的“不能召唤”效果适用，使此卡不能表侧表示召唤。
function c27491571.sumcon(e)
	-- 检查以怪兽控制者视角、自己怪兽区是否存在至少1只表侧表示且带有「鬼计」字段的怪兽；若不存在则返回true，触发“不能召唤”限制。
	return not Duel.IsExistingMatchingCard(c27491571.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- e2的发动条件与处理登记：确认自身当前可以变成里侧守备表示，且本回合尚未使用过“变成里侧守备”的效果；满足后登记1回合1次的标志，并设置操作信息。
function c27491571.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(27491571)==0 end
	c:RegisterFlagEffect(27491571,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，声明本效果的处理包含改变表示形式，对象为自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- e2的效果处理：连锁处理时，若自身仍与效果关联且为表侧表示，则将其变成里侧守备表示。
function c27491571.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身表示形式改为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数：判定怪兽是否为对方场上表侧表示且可以被变成里侧守备表示。
function c27491571.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- e3的发动条件与目标选择处理：检查是否存在可选的对方怪兽；存在则提示选择1只对方怪兽作为效果对象，并设置改变表示形式的操作信息。
function c27491571.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c27491571.filter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只满足filter条件的表侧表示怪兽，存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(c27491571.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要改变表示形式的怪兽”的提示信息，用于目标选择时的引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让操作者从对方怪兽区选择1只满足filter条件的怪兽作为效果对象，并自动与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,c27491571.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，声明本效果将改变对象怪兽的表示形式，对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- e3的效果处理：取得对象怪兽，若其仍为表侧表示且与效果关联，则将其变成里侧守备表示。
function c27491571.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得本效果所选择的第1个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式改为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
