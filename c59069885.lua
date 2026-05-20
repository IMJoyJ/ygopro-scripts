--ティスティナの抱擁
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，若非自己场上有守备力3000以上的「提斯蒂娜」怪兽存在的场合则不能发动。
-- ①：对方把场上的怪兽的效果发动时，以那1只怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：自己·对方的结束阶段，以对方场上1只里侧守备表示怪兽为对象才能发动。得到那只怪兽的控制权。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔法卡的发动、①效果（诱发即时效果，变里侧）和②效果（结束阶段诱发效果，夺取控制权）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方把场上的怪兽的效果发动时，以那1只怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成里侧表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.cpcon)
	e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，以对方场上1只里侧守备表示怪兽为对象才能发动。得到那只怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"得到控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、守备力3000以上的「提斯蒂娜」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a4) and c:IsDefenseAbove(3000)
end
-- ①效果的发动条件：对方在场上发动怪兽效果，且自己场上存在守备力3000以上的「提斯蒂娜」怪兽
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上是否存在守备力3000以上的「提斯蒂娜」怪兽（对应“若非自己场上有守备力3000以上的「提斯蒂娜」怪兽存在的场合则不能发动”的限制条件）
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的目标选择与合法性检测：以发动效果的那1只对方怪兽为对象
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsCanChangePosition() and tc:IsRelateToEffect(re) and tc:IsCanBeEffectTarget(e) end
	-- 将发动效果的怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
end
-- ①效果的处理：将作为对象的那只怪兽变成里侧守备表示
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
	-- 将目标怪兽改变为里侧守备表示
	Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动条件：自己或对方的结束阶段，且自己场上存在守备力3000以上的「提斯蒂娜」怪兽
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在守备力3000以上的「提斯蒂娜」怪兽（对应“若非自己场上有守备力3000以上的「提斯蒂娜」怪兽存在的场合则不能发动”的限制条件）
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：对方场上的里侧表示且可以改变控制权的怪兽
function s.filter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp) and c:IsControlerCanBeChanged()
end
-- ②效果的目标选择与合法性检测：以对方场上1只里侧守备表示怪兽为对象，并声明控制权转移的操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	-- 在效果发动时，检查对方场上是否存在至少1只符合条件的里侧守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 选择对方场上1只里侧守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理的操作信息为“转移1只怪兽的控制权”
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ②效果的处理：得到作为对象的那只怪兽的控制权
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的那只里侧守备表示怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让当前玩家（自己）得到目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
