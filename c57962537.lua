--ゼンマイネズミ
-- 效果：
-- 自己的主要阶段时才能发动。把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，选择自己墓地1只名字带有「发条」的怪兽表侧守备表示特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c57962537.initial_effect(c)
	-- 自己的主要阶段时才能发动。把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，选择自己墓地1只名字带有「发条」的怪兽表侧守备表示特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57962537,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c57962537.spcon)
	e1:SetTarget(c57962537.sptg)
	e1:SetOperation(c57962537.spop)
	c:RegisterEffect(e1)
end
-- 判定自身是否处于表侧攻击表示（作为发动条件）
function c57962537.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤墓地中可以表侧守备表示特殊召唤的「发条」怪兽
function c57962537.filter(c,e,tp)
	return c:IsSetCard(0x58) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的对象选择与可行性检查
function c57962537.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57962537.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「发条」怪兽
		and Duel.IsExistingTarget(c57962537.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「发条」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57962537.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将自身变更为表侧守备表示，并将目标怪兽表侧守备表示特殊召唤
function c57962537.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的特殊召唤目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 将自身变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
