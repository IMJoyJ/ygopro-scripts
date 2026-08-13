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
-- 效果①的发动条件判定：攻击怪兽为对方控制且为直接攻击（攻击目标为空）时满足条件。
function c49966595.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽由对方控制（1-tp）且攻击目标为nil（直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 筛选卡组中持有「灰篮」字段、且能被当前效果由tp玩家表侧攻击表示特殊召唤的怪兽。
function c49966595.spfilter1(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果①的发动时点合法性检查：自己场上无怪兽、自己主要怪兽区有空位、且卡组存在满足条件的「灰篮」怪兽；满足后设置操作信息。
function c49966595.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：自己场上没有怪兽（自己主要怪兽区怪兽数量为0）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 发动条件：自己主要怪兽区存在可用的空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：卡组中存在至少1只满足spfilter1的「灰篮」怪兽。
		and Duel.IsExistingMatchingCard(c49966595.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁的操作信息：将从卡组特殊召唤1只怪兽（用于相关效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：再次确认自己场上无怪兽且有空格，然后从卡组选1只「灰篮」怪兽表侧攻击表示特殊召唤。
function c49966595.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上已有怪兽，则效果不适用并终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0 then return end
	-- 效果处理时若自己场上没有可用怪兽区空格，则效果不适用并终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张满足spfilter1的「灰篮」怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c49966595.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己（tp）场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 效果②的发动条件判定：攻击怪兽为自己控制且属于「灰篮」字段，并且是直接攻击。
function c49966595.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local c=Duel.GetAttacker()
	-- 判断攻击怪兽为自己控制、卡名含有「灰篮」字段、且攻击目标为nil（直接攻击）。
	return c:IsControler(tp) and c:IsSetCard(0xd1) and Duel.GetAttackTarget()==nil
end
-- 筛选对方墓地中能够由当前效果被tp玩家特殊召唤到对方场上的怪兽（表侧表示）。
function c49966595.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果②的取对象发动检查：对方场上无怪兽、对方场上有空格、对方墓地存在至少1只满足条件的对象；进行对象选择并登记操作信息。
function c49966595.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c49966595.spfilter2(chkc,e,tp) end
	-- 发动条件：对方场上没有怪兽（对方主要怪兽区怪兽数量为0）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
		-- 发动条件：对方主要怪兽区存在可用的空格。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 发动条件：对方墓地存在至少1只可作为对象且满足spfilter2的怪兽。
		and Duel.IsExistingTarget(c49966595.spfilter2,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只满足条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c49966595.spfilter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 登记本次连锁的操作信息：将选择的对象怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②处理：再次确认对方场上无怪兽且有空格，取得对象怪兽并特殊召唤到对方场上。
function c49966595.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若对方场上已有怪兽，则效果不适用并终止处理。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0 then return end
	-- 效果处理时若对方场上没有可用怪兽区空格，则效果不适用并终止处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽由tp玩家特殊召唤到对方（1-tp）场上，表侧表示。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
