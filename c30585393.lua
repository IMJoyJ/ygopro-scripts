--リボーン・パズル
-- 效果：
-- 只让自己场上的怪兽1只被卡的效果破坏的场合，选择那1只才能发动。选择的怪兽在自己场上特殊召唤。
function c30585393.initial_effect(c)
	-- 只让自己场上的怪兽1只被卡的效果破坏的场合，选择那1只才能发动。选择的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c30585393.target)
	e1:SetOperation(c30585393.activate)
	c:RegisterEffect(e1)
end
-- 只让自己场上的怪兽1只被卡的效果破坏的场合，选择那1只才能发动。
function c30585393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return eg:GetCount()==1 and tc:IsPreviousControler(tp) and tc:IsPreviousLocation(LOCATION_MZONE)
		-- 检查玩家场上怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and tc:IsReason(REASON_EFFECT)
		and tc:IsCanBeEffectTarget(e) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将目标怪兽设为效果对象
	Duel.SetTargetCard(tc)
	-- 设置连锁处理信息，表明将要把目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 选择的怪兽在自己场上特殊召唤。
function c30585393.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
