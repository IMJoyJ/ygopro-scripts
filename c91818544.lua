--WAKE CUP！ モカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只里侧守备表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成表侧攻击表示。
-- ②：这张卡反转的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽攻击力上升1000，结束阶段送去墓地。
-- ③：自己结束阶段才能发动。这张卡变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①手卡特召及改变表示形式、②反转时增加攻击力及结束阶段送墓、③自己结束阶段变里侧守备表示三个效果
function s.initial_effect(c)
	-- ①：以场上1只里侧守备表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽攻击力上升1000，结束阶段送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段才能发动。这张卡变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"变成里侧守备表示"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.poscon)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上的里侧守备表示怪兽
function s.cfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 效果①（手卡特召）的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以作为对象的里侧守备表示怪兽
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 玩家选择1只里侧守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁信息：包含改变目标怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①（手卡特召）的效果处理函数，将自身特殊召唤并使目标怪兽变成表侧攻击表示
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否仍与连锁相关，并成功将自身表侧表示特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and tc:IsRelateToChain() and not tc:IsAttackPos() then
		-- 将作为对象的怪兽变成表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
-- 过滤条件：场上的表侧表示怪兽
function s.cfilter1(c)
	return c:IsFaceup()
end
-- 效果②（反转时升攻送墓）的发动准备与合法性检测函数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter1(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②（反转时升攻送墓）的效果处理函数，使目标怪兽攻击力上升1000，并注册结束阶段送去墓地的效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() then
		-- 那只怪兽攻击力上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 结束阶段送去墓地。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetOperation(s.tgop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 结束阶段将该怪兽送去墓地的延迟效果处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该怪兽因效果送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 效果③（结束阶段变里侧守备）的发动条件检测函数
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 效果③（结束阶段变里侧守备）的发动准备与合法性检测函数
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() end
	-- 设置连锁信息：包含改变自身表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果③（结束阶段变里侧守备）的效果处理函数
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER) then
		-- 将这张卡变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
