--武神降臨
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，选择自己墓地1只名字带有「武神」的怪兽和从游戏中除外的1只自己的名字带有「武神」的怪兽才能发动。选择的2只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是兽族·兽战士族·鸟兽族怪兽的超量召唤不能使用。
function c73906480.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，选择自己墓地1只名字带有「武神」的怪兽和从游戏中除外的1只自己的名字带有「武神」的怪兽才能发动。选择的2只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是兽族·兽战士族·鸟兽族怪兽的超量召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c73906480.condition)
	e1:SetTarget(c73906480.target)
	e1:SetOperation(c73906480.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件判定函数
function c73906480.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上没有怪兽存在且对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤自己墓地中可以特殊召唤的「武神」怪兽
function c73906480.spfilter1(c,e,tp)
	return c:IsSetCard(0x88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤自己除外区中表侧表示且可以特殊召唤的「武神」怪兽
function c73906480.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的对象选择与合法性检测函数
function c73906480.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上的空怪兽区域是否在2个以上
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判定自己墓地是否存在可以作为对象的「武神」怪兽
		and Duel.IsExistingTarget(c73906480.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判定自己除外区是否存在可以作为对象的「武神」怪兽
		and Duel.IsExistingTarget(c73906480.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	-- 设置选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「武神」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c73906480.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外区1只「武神」怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c73906480.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	g1:Merge(g2)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 定义效果处理函数
function c73906480.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的空怪兽区域不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=2 then return end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 将目标怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是兽族·兽战士族·鸟兽族怪兽的超量召唤不能使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(c73906480.xyzlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 定义超量素材限制判定函数，限制只能用于兽族、兽战士族、鸟兽族怪兽的超量召唤
function c73906480.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
