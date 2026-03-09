--凶導の白聖骸
-- 效果：
-- 「凶导的葬列」降临
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡仪式召唤的场合，以场上2只表侧表示怪兽为对象才能发动。那之内1只的攻击力上升另1只的攻击力数值。
-- ②：8星以上的自己的「教导」怪兽不会被战斗破坏。
-- ③：从对方的额外卡组有怪兽特殊召唤的场合才能发动。把对方的额外卡组确认，那之内的1只怪兽送去墓地。
function c48654323.initial_effect(c)
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
-- 判断此卡是否为仪式召唤
function c48654323.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 筛选场上满足条件的怪兽作为第一目标（必须表侧表示且存在第二目标）
function c48654323.atktgfilter1(c,tp)
	-- 检查是否存在满足条件的第二目标（必须表侧表示且攻击力大于0）
	return c:IsFaceup() and Duel.IsExistingTarget(c48654323.atktgfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 筛选场上满足条件的怪兽作为第二目标（必须表侧表示且攻击力大于0）
function c48654323.atktgfilter2(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 选择两个目标怪兽，一个作为攻击力上升对象，另一个作为提供攻击力数值的对象
function c48654323.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择目标的条件（即是否存在符合条件的第一目标）
	if chk==0 then return Duel.IsExistingTarget(c48654323.atktgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第一个目标怪兽
	local g=Duel.SelectTarget(tp,c48654323.atktgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第二个目标怪兽
	Duel.SelectTarget(tp,c48654323.atktgfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g)
end
-- 筛选与效果相关的怪兽（必须存在于连锁中且表侧表示）
function c48654323.atkfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 筛选能作为攻击力上升对象的怪兽（其目标组中存在满足条件的第二目标）
function c48654323.atkupfilter(c,g)
	return g:FilterCount(c48654323.atktgfilter2,c)>0
end
-- 处理攻击力上升效果，将选定怪兽的攻击力提升至另一目标怪兽的攻击力值
function c48654323.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡片组，并筛选出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c48654323.atkfilter,nil,e)
	if #g==2 then
		-- 提示玩家选择要上升攻击力的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48654323,2))  --"请选择要上升攻击力的怪兽"
		local hc=g:FilterSelect(tp,c48654323.atkupfilter,1,1,nil,g):GetFirst()
		if not hc then return end
		-- 获取第二个目标怪兽（即提供攻击力数值的那个）
		local tc=g:Filter(aux.TRUE,hc):GetFirst()
		-- 创建并注册攻击力变更效果，使选定怪兽获得另一个目标怪兽的攻击力值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetAttack())
		hc:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否为教导族且等级不低于8星
function c48654323.indtg(e,c)
	return c:IsSetCard(0x145) and c:IsLevelAbove(8)
end
-- 筛选从额外卡组特殊召唤且前控制者为对方的怪兽
function c48654323.tgfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(1-tp)
end
-- 判断是否有从对方额外卡组特殊召唤的怪兽
function c48654323.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48654323.tgfilter,1,nil,tp)
end
-- 设置发动效果时的操作信息，准备将对方额外卡组的怪兽送去墓地
function c48654323.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方额外卡组是否存在怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	-- 设置操作信息，指定要处理的目标为对方额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 处理将对方额外卡组怪兽送去墓地的效果
function c48654323.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的所有怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	-- 确认对方额外卡组中的所有怪兽
	Duel.ConfirmCards(tp,g,true)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
	-- 将选定的怪兽送去墓地
	Duel.SendtoGrave(tg,REASON_EFFECT)
	-- 将对方额外卡组洗切
	Duel.ShuffleExtra(1-tp)
end
