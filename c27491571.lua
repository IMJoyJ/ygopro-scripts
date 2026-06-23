--ゴーストリックの魔女
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。
function c27491571.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合不能让这张卡表侧表示召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c27491571.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27491571,0))  --"变成里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c27491571.postg)
	e2:SetOperation(c27491571.posop)
	c:RegisterEffect(e2)
	-- 1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示
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
-- 过滤函数，用于判断场上是否存在名字带有「鬼计」的表侧表示怪兽
function c27491571.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 判断自己场上有名字带有「鬼计」的怪兽存在时，该卡不能召唤
function c27491571.sumcon(e)
	-- 如果自己场上没有名字带有「鬼计」的怪兽，则该卡可以召唤
	return not Duel.IsExistingMatchingCard(c27491571.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时的条件，判断该卡是否可以变成里侧守备表示
function c27491571.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(27491571)==0 end
	c:RegisterFlagEffect(27491571,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，表示该效果会改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 处理效果，将该卡变成里侧守备表示
function c27491571.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将该卡改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数，用于判断对方场上是否存在可以变成里侧守备表示的表侧表示怪兽
function c27491571.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果处理时的条件，选择对方场上可以变成里侧守备表示的表侧表示怪兽
function c27491571.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c27491571.filter(chkc) end
	-- 检查对方场上是否存在可以变成里侧守备表示的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c27491571.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上可以变成里侧守备表示的表侧表示怪兽
	local g=Duel.SelectTarget(tp,c27491571.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示该效果会改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果，将选择的对方怪兽变成里侧守备表示
function c27491571.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
