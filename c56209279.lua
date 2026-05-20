--インフェルニティ・ネクロマンサー
-- 效果：
-- ①：这张卡召唤的场合发动。这张卡变成守备表示。
-- ②：1回合1次，自己手卡是0张的场合，以「永火死灵师」以外的自己墓地1只「永火」怪兽为对象才能发动。那只怪兽特殊召唤。
function c56209279.initial_effect(c)
	-- ①：这张卡召唤的场合发动。这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56209279,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c56209279.potg)
	e1:SetOperation(c56209279.poop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己手卡是0张的场合，以「永火死灵师」以外的自己墓地1只「永火」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56209279,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c56209279.spcon)
	e2:SetTarget(c56209279.sptg)
	e2:SetOperation(c56209279.spop)
	c:RegisterEffect(e2)
end
-- 效果①（变成守备表示）的发动准备与检测函数
function c56209279.potg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置当前连锁的操作信息为：将这张卡（1张）改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果①（变成守备表示）的效果处理函数
function c56209279.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡变成表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 效果②（特殊召唤）的发动条件检测函数
function c56209279.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自身效果未被无效，且自己手卡数量为0张时可以发动
	return not e:GetHandler():IsDisabled() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 过滤墓地中「永火死灵师」以外的「永火」怪兽且可以特殊召唤的卡
function c56209279.filter(c,e,tp)
	return c:IsSetCard(0xb) and not c:IsCode(56209279) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特殊召唤）的对象选择与发动检测函数
function c56209279.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c56209279.filter(chkc,e,tp) end
	-- 发动检测：自己场上必须有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只满足条件的「永火」怪兽
		and Duel.IsExistingTarget(c56209279.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「永火」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56209279.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为：将选择的对象怪兽（1张）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（特殊召唤）的效果处理函数
function c56209279.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
