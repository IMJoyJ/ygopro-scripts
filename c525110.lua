--プチトマボー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把最多2只名字带有「番茄小子」的怪兽特殊召唤。这个效果特殊召唤的怪兽这个回合不能作为同调素材。
function c525110.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把最多2只名字带有「番茄小子」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(525110,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c525110.condition)
	e1:SetTarget(c525110.target)
	e1:SetOperation(c525110.operation)
	c:RegisterEffect(e1)
end
-- 判断触发条件：自身被战斗破坏后处于墓地，即满足“这张卡被战斗破坏送去墓地时”这一时点。
function c525110.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选卡组中满足名字带有「番茄小子」字段且可以被效果特殊召唤的怪兽。
function c525110.filter(c,e,tp)
	return c:IsSetCard(0x5b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检查：我方主要怪兽区有空位，且卡组中存在至少1只符合条件的「番茄小子」怪兽可供特殊召唤。
function c525110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否留有可用空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的「番茄小子」怪兽。
		and Duel.IsExistingMatchingCard(c525110.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息，声明本效果包含特殊召唤，并预计从卡组特殊召唤1只怪兽（实际数量在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：计算可特殊召唤的空位数，若无空位则终止；若空位≥2则最多召唤2只；若场上有「青眼精灵龙」效果适用中则限制为1只；让玩家从卡组选择1~ft只符合条件的「番茄小子」怪兽；依次将他们表侧表示特殊召唤，并给这些怪兽附加“这个回合不能作为同调素材”的无效化免疫效果；最后完成特殊召唤处理。
function c525110.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方主要怪兽区当前可用的空格数量，用于决定特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发出选择卡片的提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1至ft只满足条件的「番茄小子」怪兽（ft为限制后的可召唤数量）。
	local g=Duel.SelectMatchingCard(tp,c525110.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		local t1=g:GetFirst()
		local t2=g:GetNext()
		-- 将第一只选择的怪兽以表侧表示特殊召唤，作为连续特殊召唤的其中一步。
		Duel.SpecialSummonStep(t1,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽这个回合不能作为同调素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		t1:RegisterEffect(e1)
		if t2 then
			-- 将第二只选择的怪兽（若存在）以表侧表示特殊召唤。
			Duel.SpecialSummonStep(t2,0,tp,tp,false,false,POS_FACEUP)
			local e2=e1:Clone()
			t2:RegisterEffect(e2)
		end
		-- 完成所有特殊召唤步骤，统一结算本次连续特殊召唤的结果。
		Duel.SpecialSummonComplete()
	end
end
