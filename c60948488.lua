--クロニクル・マジシャン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有原本攻击力或者原本守备力是2500的怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以自己场上1只「黑魔术师」或者「青眼白龙」为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2500。
function c60948488.initial_effect(c)
	-- 注册卡片记述的特定卡片密码（黑魔术师、青眼白龙），用于卡片关联检索或效果处理。
	aux.AddCodeList(c,46986414,89631139)
	-- ①：自己场上有原本攻击力或者原本守备力是2500的怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60948488,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,60948488)
	e1:SetCondition(c60948488.spcon)
	e1:SetTarget(c60948488.sptg)
	e1:SetOperation(c60948488.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以自己场上1只「黑魔术师」或者「青眼白龙」为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60948488,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,60948489)
	e3:SetTarget(c60948488.atktg)
	e3:SetOperation(c60948488.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示存在且原本攻击力或原本守备力为2500的怪兽。
function c60948488.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
		and (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500)
end
-- 效果①的发动条件：召唤·特殊召唤成功的怪兽中存在满足过滤条件的怪兽。
function c60948488.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60948488.cfilter,1,nil,tp)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息）。
function c60948488.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理中的操作信息：将自身（1张卡）特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：若自身仍在手卡，则将自身守备表示特殊召唤。
function c60948488.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤到发动效果的玩家场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤条件：自己场上表侧表示的「黑魔术师」或「青眼白龙」。
function c60948488.atkfilter(c)
	return c:IsFaceup() and c:IsCode(46986414,89631139)
end
-- 效果②的发动准备与目标选择（检测并选择自己场上1只「黑魔术师」或「青眼白龙」作为对象）。
function c60948488.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and c60948488.atkfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的「黑魔术师」或「青眼白龙」。
	if chk==0 then return Duel.IsExistingTarget(c60948488.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c60948488.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理：使作为对象的怪兽的攻击力和守备力直到回合结束时上升2500。
function c60948488.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升2500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2500)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
