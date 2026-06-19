--朽ち果てた武将
-- 效果：
-- 这张卡召唤成功时，可以从手卡特殊召唤1只「僵尸虎」。这张卡对对方直接攻击成功时，对方随机丢弃1张手卡。
function c10209545.initial_effect(c)
	-- 这张卡召唤成功时可以发动。从手卡特殊召唤1只「僵尸虎」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10209545,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c10209545.sptg)
	e1:SetOperation(c10209545.spop)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方战斗伤害的场合发动。对方随机丢弃1张手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10209545,1))
	e2:SetCategory(CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c10209545.hdcon)
	e2:SetTarget(c10209545.hdtg)
	e2:SetOperation(c10209545.hdop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中的「僵尸虎」且可以特殊召唤的怪兽。
function c10209545.filter(c,e,tp)
	return c:IsCode(47693640) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的启动和条件判断逻辑。
function c10209545.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在「僵尸虎」。
		and Duel.IsExistingMatchingCard(c10209545.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的执行逻辑。
function c10209545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有空余的怪兽区域，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示语：选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中1只「僵尸虎」。
	local g=Duel.SelectMatchingCard(tp,c10209545.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 丢弃手卡效果的发动条件判定函数。
function c10209545.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认伤害是由对方承受，且这次攻击是直接攻击（没有攻击目标怪兽）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 丢弃手卡效果的对象确认与效果准备逻辑。
function c10209545.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,0,0,1-tp,1)
end
-- 执行对方随机丢弃手卡的操作。
function c10209545.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选出的对方手卡丢弃送去墓地。
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
