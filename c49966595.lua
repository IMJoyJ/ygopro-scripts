--グレイドル・パラサイト
-- 效果：
-- 「灰篮寄生体」的①②的效果1回合各能使用1次。
-- ①：对方怪兽的直接攻击宣言时才能把这个效果发动。自己场上没有怪兽存在的场合，从卡组把1只「灰篮」怪兽攻击表示特殊召唤。
-- ②：自己的「灰篮」怪兽的直接攻击宣言时，以对方墓地1只怪兽为对象才能发动。对方场上没有怪兽存在的场合，那只怪兽在对方场上特殊召唤。
function c49966595.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的直接攻击宣言时才能把这个效果发动。自己场上没有怪兽存在的场合，从卡组把1只「灰篮」怪兽攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,49966595)
	e2:SetCondition(c49966595.spcon1)
	e2:SetTarget(c49966595.sptg1)
	e2:SetOperation(c49966595.spop1)
	c:RegisterEffect(e2)
	-- ②：自己的「灰篮」怪兽的直接攻击宣言时，以对方墓地1只怪兽为对象才能发动。对方场上没有怪兽存在的场合，那只怪兽在对方场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,49966596)
	e3:SetCondition(c49966595.spcon2)
	e3:SetTarget(c49966595.sptg2)
	e3:SetOperation(c49966595.spop2)
	c:RegisterEffect(e3)
end
-- 效果发动条件：对方怪兽进行直接攻击宣言且无攻击目标
function c49966595.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽进行直接攻击宣言且无攻击目标
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤函数：筛选「灰篮」怪兽且可特殊召唤
function c49966595.spfilter1(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理时点：检查是否满足特殊召唤条件
function c49966595.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 己方场上没有怪兽存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 己方场上存在可用召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 卡组中存在符合条件的「灰篮」怪兽
		and Duel.IsExistingMatchingCard(c49966595.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备从卡组特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行特殊召唤操作
function c49966595.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 己方场上已有怪兽存在则不执行
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0 then return end
	-- 己方场上无可用召唤位置则不执行
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的「灰篮」怪兽
	local g=Duel.SelectMatchingCard(tp,c49966595.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以攻击表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 效果发动条件：己方「灰篮」怪兽进行直接攻击宣言且无攻击目标
function c49966595.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local c=Duel.GetAttacker()
	-- 己方「灰篮」怪兽进行直接攻击宣言且无攻击目标
	return c:IsControler(tp) and c:IsSetCard(0xd1) and Duel.GetAttackTarget()==nil
end
-- 过滤函数：筛选可特殊召唤到对方场上的怪兽
function c49966595.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果处理时点：检查是否满足特殊召唤条件
function c49966595.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c49966595.spfilter2(chkc,e,tp) end
	-- 对方场上没有怪兽存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
		-- 对方场上存在可用召唤位置
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 对方墓地中存在符合条件的怪兽
		and Duel.IsExistingTarget(c49966595.spfilter2,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地中选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c49966595.spfilter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：准备将对方墓地的怪兽特殊召唤到对方场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：执行特殊召唤操作
function c49966595.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上已有怪兽存在则不执行
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0 then return end
	-- 对方场上无可用召唤位置则不执行
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示特殊召唤到对方场上
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
