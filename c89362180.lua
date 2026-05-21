--ナチュラル・ボーン・サウルス
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡的种族·属性变成恐龙族·地属性。
-- ●这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的种族变成不死族。
function c89362180.initial_effect(c)
	-- 为卡片添加二重怪兽的通用属性与规则
	aux.EnableDualAttribute(c)
	-- ●这张卡的种族·属性变成恐龙族·地属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果生效条件为该卡处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetValue(ATTRIBUTE_EARTH)
	c:RegisterEffect(e1)
	-- ●这张卡的种族·属性变成恐龙族·地属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_MZONE)
	-- 设置效果生效条件为该卡处于再度召唤状态
	e2:SetCondition(aux.IsDualState)
	e2:SetValue(RACE_DINOSAUR)
	c:RegisterEffect(e2)
	-- ●这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的种族变成不死族。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89362180,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCondition(c89362180.spcon)
	e3:SetTarget(c89362180.sptg)
	e3:SetOperation(c89362180.spop)
	c:RegisterEffect(e3)
end
-- 判断特殊召唤效果的发动条件：自身处于再度召唤状态，且战斗破坏了怪兽并送去墓地
function c89362180.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDualState() then return false end
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 特殊召唤效果的发动检测，获取战斗破坏的怪兽并判断是否能特殊召唤
function c89362180.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 在第1阶段（chk==0）检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将被战斗破坏的怪兽设定为效果处理的对象
	Duel.SetTargetCard(bc)
	-- 设置特殊召唤的操作信息，用于后续连锁处理和卡片效果检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 特殊召唤效果的效果处理：将目标怪兽特殊召唤并将其种族变更为不死族
function c89362180.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标怪兽（即被战斗破坏的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍与效果相关，则将其在自己场上以表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 这个效果特殊召唤的怪兽的种族变成不死族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
