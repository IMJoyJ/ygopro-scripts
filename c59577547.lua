--転生炎獣パロー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以自己墓地1只「转生炎兽」怪兽为对象才能发动。这张卡的攻击力变成和那只怪兽的攻击力相同。
-- ③：把这张卡解放才能发动。自己回复2000基本分。
function c59577547.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59577547,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c59577547.spcon)
	e1:SetTarget(c59577547.sptg)
	e1:SetOperation(c59577547.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以自己墓地1只「转生炎兽」怪兽为对象才能发动。这张卡的攻击力变成和那只怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59577547,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c59577547.atktg)
	e2:SetOperation(c59577547.atkop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：把这张卡解放才能发动。自己回复2000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59577547,2))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,59577547)
	e3:SetCost(c59577547.cost)
	e3:SetTarget(c59577547.target)
	e3:SetOperation(c59577547.operation)
	c:RegisterEffect(e3)
end
-- ①效果发动条件：对方怪兽攻击宣言时
function c59577547.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断进行攻击宣言的怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果发动准备：检查自身是否能从手卡特殊召唤，并设置特殊召唤的操作信息
function c59577547.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置特殊召唤的操作信息，表示将手卡的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- ①效果处理：将这张卡从手卡攻击表示特殊召唤
function c59577547.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 过滤条件：自己墓地的「转生炎兽」怪兽，且攻击力与这张卡当前的攻击力不同
function c59577547.filter(c,atk)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x119) and c:GetAttack()~=atk
end
-- ②效果发动准备：选择自己墓地1只「转生炎兽」怪兽作为对象
function c59577547.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59577547.filter(chkc,c:GetAttack()) end
	if chk==0 then return c:IsRelateToEffect(e)
		-- 检查自己墓地是否存在符合过滤条件的「转生炎兽」怪兽
		and Duel.IsExistingTarget(c59577547.filter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttack()) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只符合条件的「转生炎兽」怪兽作为效果对象
	Duel.SelectTarget(tp,c59577547.filter,tp,LOCATION_GRAVE,0,1,1,nil,c:GetAttack())
end
-- ②效果处理：使这张卡的攻击力变成和作为对象的怪兽的攻击力相同
function c59577547.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力变成和那只怪兽的攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③效果发动代价：将这张卡解放
function c59577547.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ③效果发动准备：设置回复基本分的对象玩家、数值及操作信息
function c59577547.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复基本分的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为2000
	Duel.SetTargetParam(2000)
	-- 设置回复基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
-- ③效果处理：自己回复2000基本分
function c59577547.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的回复对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复操作，使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
