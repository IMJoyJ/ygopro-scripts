--アロマセラフィ－アンゼリカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己墓地1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
-- ②：这张卡在墓地存在，自己基本分比对方多，自己场上有「芳香」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c16759958.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己墓地1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16759958,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,16759958)
	e1:SetCost(c16759958.reccost)
	e1:SetTarget(c16759958.rectg)
	e1:SetOperation(c16759958.recop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己基本分比对方多，自己场上有「芳香」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16759958,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16759959)
	e2:SetCondition(c16759958.spcon)
	e2:SetTarget(c16759958.sptg)
	e2:SetOperation(c16759958.spop)
	c:RegisterEffect(e2)
end
-- 丢弃自身作为效果的发动代价
function c16759958.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身丢入墓地作为效果的发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤满足「芳香」卡族且攻击力大于0的怪兽
function c16759958.recfilter(c)
	return c:IsSetCard(0xc9) and c:GetAttack()>0
end
-- 选择满足条件的墓地「芳香」怪兽作为效果对象
function c16759958.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16759958.recfilter(chkc) end
	-- 检查是否存在满足条件的墓地「芳香」怪兽
	if chk==0 then return Duel.IsExistingTarget(c16759958.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地「芳香」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c16759958.recfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时的回复数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
-- 处理效果的发动，使玩家回复对应攻击力的LP
function c16759958.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 使玩家回复对象怪兽攻击力的LP
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 过滤场上正面表示的「芳香」卡族怪兽
function c16759958.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- 判断是否满足效果发动条件：己方LP高于对方且己方场上存在「芳香」怪兽
function c16759958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果发动条件：己方LP高于对方且己方场上存在「芳香」怪兽
	return Duel.GetLP(tp)>Duel.GetLP(1-tp) and Duel.IsExistingMatchingCard(c16759958.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断是否满足特殊召唤的条件
function c16759958.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的特殊召唤信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，将自身特殊召唤到场上
function c16759958.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤成功后，设置该卡离开场时的去向为除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
