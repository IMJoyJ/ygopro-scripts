--機械複製術
-- 效果：
-- ①：以自己场上1只攻击力500以下的机械族怪兽为对象才能发动。把最多2只那只怪兽的同名怪兽从卡组特殊召唤。
function c63995093.initial_effect(c)
	-- ①：以自己场上1只攻击力500以下的机械族怪兽为对象才能发动。把最多2只那只怪兽的同名怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63995093.target)
	e1:SetOperation(c63995093.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、攻击力500以下、且卡组中存在其同名卡可特殊召唤的机械族怪兽
function c63995093.filter(c,e,tp)
	return c:IsFaceup() and c:IsAttackBelow(500) and c:IsRace(RACE_MACHINE)
		-- 检查卡组中是否存在至少1张该怪兽的同名卡，且该同名卡可以被特殊召唤
		and Duel.IsExistingMatchingCard(c63995093.filter2,tp,LOCATION_DECK,0,1,nil,c:GetCode(),e,tp)
end
-- 过滤卡组中与目标怪兽同名且可以被特殊召唤的卡
function c63995093.filter2(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测
function c63995093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63995093.filter(chkc,e,tp) end
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查自己场上是否存在满足条件的、可作为效果对象的机械族怪兽
		and Duel.IsExistingTarget(c63995093.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63995093,0))  --"请选择攻击力500以下的1只机械族怪兽"
	-- 让玩家选择自己场上1只满足条件的机械族怪兽作为效果对象
	Duel.SelectTarget(tp,c63995093.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含从卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行逻辑，包括计算可召唤数量、选择同名卡并特殊召唤
function c63995093.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择最多等同于可用怪兽区域数量（且不超过2张）的该怪兽的同名卡
		local sg=Duel.SelectMatchingCard(tp,c63995093.filter2,tp,LOCATION_DECK,0,1,ft,nil,tc:GetCode(),e,tp)
		if sg:GetCount()>0 then
			-- 将选择的同名怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
