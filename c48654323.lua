--凶導の白聖骸
-- 效果：
-- 「凶导的葬列」降临
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡仪式召唤的场合，以场上2只表侧表示怪兽为对象才能发动。那之内1只的攻击力上升另1只的攻击力数值。
-- ②：8星以上的自己的「教导」怪兽不会被战斗破坏。
-- ③：从对方的额外卡组有怪兽特殊召唤的场合才能发动。把对方的额外卡组确认，那之内的1只怪兽送去墓地。
function c48654323.initial_effect(c)
	-- 放入「凶导的葬列」的卡名列表
	aux.AddCodeList(c,60921537)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合，以场上2只表侧表示怪兽为对象才能发动。那之内1只的攻击力上升另1只的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48654323,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c48654323.atkcon)
	e1:SetTarget(c48654323.atktg)
	e1:SetOperation(c48654323.atkop)
	c:RegisterEffect(e1)
	-- ②：8星以上的自己的「教导」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c48654323.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：从对方的额外卡组有怪兽特殊召唤的场合才能发动。把对方的额外卡组确认，那之内的1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48654323,1))  --"额外卡组送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,48654323)
	e3:SetCondition(c48654323.tgcon)
	e3:SetTarget(c48654323.tgtg)
	e3:SetOperation(c48654323.tgop)
	c:RegisterEffect(e3)
end
-- 攻击力上升效果的发动条件
function c48654323.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤第一只合法的表侧表示怪兽（场上还存在另一只攻击力大于0的表侧表示怪兽）
function c48654323.atktgfilter1(c,tp)
	-- 返回该怪兽表侧表示且场上存在另一只表侧表示且攻击力大于0的怪兽
	return c:IsFaceup() and Duel.IsExistingTarget(c48654323.atktgfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 过滤第二只合法的表侧表示怪兽（表侧表示且攻击力大于0）
function c48654323.atktgfilter2(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 攻击力上升效果的发动靶点
function c48654323.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 靶点检查：场上是否存在两只符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c48654323.atktgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 给玩家提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第一只作为对象的表侧表示怪兽
	local g=Duel.SelectTarget(tp,c48654323.atktgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 给玩家提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第二只作为对象的表侧表示怪兽
	Duel.SelectTarget(tp,c48654323.atktgfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g)
end
-- 过滤仍与效果有关联且表侧表示的已选择对象
function c48654323.atkfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 过滤可以用作被提升攻击力的怪兽（必须能跟另一只攻击力大于0的怪兽形成有效组合）
function c48654323.atkupfilter(c,g)
	return g:FilterCount(c48654323.atktgfilter2,c)>0
end
-- 攻击力上升效果的处理
function c48654323.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果有关联的对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c48654323.atkfilter,nil,e)
	if #g==2 then
		-- 给玩家提示信息：请选择要上升攻击力的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48654323,2))  --"请选择要上升攻击力的怪兽"
		local hc=g:FilterSelect(tp,c48654323.atkupfilter,1,1,nil,g):GetFirst()
		if not hc then return end
		-- 获取另一只作为攻击力上升数值来源的怪兽
		local tc=g:Filter(aux.TRUE,hc):GetFirst()
		-- 那之内1只的攻击力上升另1只的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetAttack())
		hc:RegisterEffect(e1)
	end
end
-- 不会被战斗破坏效果的影响对象过滤（8星以上的自己的「教导」怪兽）
function c48654323.indtg(e,c)
	return c:IsSetCard(0x145) and c:IsLevelAbove(8)
end
-- 过滤从对方额外卡组特殊召唤的怪兽
function c48654323.tgfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(1-tp)
end
-- 对方额外卡组送去墓地效果的发动条件
function c48654323.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48654323.tgfilter,1,nil,tp)
end
-- 对方额外卡组送去墓地效果的发动靶点
function c48654323.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 靶点检查：对方额外卡组是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	-- 设置操作信息：将对方额外卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 对方额外卡组送去墓地效果的处理
function c48654323.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的全部卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	-- 给玩家确认对方的额外卡组
	Duel.ConfirmCards(tp,g,true)
	-- 给玩家提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
	-- 将对方额外卡组被选中的卡送去墓地
	Duel.SendtoGrave(tg,REASON_EFFECT)
	-- 洗切对方的额外卡组
	Duel.ShuffleExtra(1-tp)
end
