--TG ドリル・フィッシュ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有「科技属」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：自己的「科技属」怪兽给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c30348744.initial_effect(c)
	-- ②：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽只有「科技属」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,30348744)
	e2:SetCondition(c30348744.spcon)
	e2:SetTarget(c30348744.sptg)
	e2:SetOperation(c30348744.spop)
	c:RegisterEffect(e2)
	-- ③：自己的「科技属」怪兽给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,30348745)
	e3:SetCondition(c30348744.descon)
	e3:SetTarget(c30348744.destg)
	e3:SetOperation(c30348744.desop)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于判断场上怪兽是否为里侧表示或不是「科技属」怪兽。
function c30348744.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x27)
end
-- 判断自己场上是否只有「科技属」怪兽（且至少有一只怪兽）。
function c30348744.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽组。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and not g:IsExists(c30348744.cfilter,1,nil)
end
-- 设置特殊召唤的发动条件，检查是否有足够的召唤位置和卡牌是否可以被特殊召唤。
function c30348744.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将卡片特殊召唤到场上。
function c30348744.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤动作，以正面表示形式将卡片特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足破坏效果的发动条件，即是否为己方「科技属」怪兽造成战斗伤害。
function c30348744.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0x27)
end
-- 设置破坏效果的目标选择逻辑，选择对方场上的任意一只怪兽作为目标。
function c30348744.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少一只可以被选择的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一个目标怪兽。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作，将目标怪兽破坏。
function c30348744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中选定的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行破坏动作，以效果原因将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
