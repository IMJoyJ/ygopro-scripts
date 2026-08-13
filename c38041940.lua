--シード・オブ・フレイム
-- 效果：
-- 自己场上存在的这张卡被卡的效果破坏送去墓地时才能发动。自己墓地存在的「火焰花种」以外的1只4星以下的植物族怪兽在自己场上特殊召唤，在对方场上把1只「花种衍生物」（植物族·地·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c38041940.initial_effect(c)
	-- 对应效果原文：‘自己场上存在的这张卡被卡的效果破坏送去墓地时才能发动。’ 此段创建并注册了这个诱发效果的完整框架。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38041940,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c38041940.condition)
	e1:SetTarget(c38041940.target)
	e1:SetOperation(c38041940.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡被卡的效果破坏后从场上送去墓地，且破坏前的持有控制权属于发动玩家。
function c38041940.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp)
end
-- 筛选条件：墓地中4星以下、植物族、卡名不是「火焰花种」且能被特殊召唤的怪兽。
function c38041940.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and not c:IsCode(38041940) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测：先验证选中对象位于己方墓地且满足筛选；再检查双方怪兽区均有空位、不受青眼精灵龙效果影响、墓地存在可特殊召唤的目标且能特殊召唤花种衍生物。
function c38041940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38041940.spfilter(chkc,e,tp) end
	-- 检查己方和对方的主要怪兽区是否都有可用空格，以确保后续两个特殊召唤都能进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查墓地是否存在1只以上满足spfilter条件的植物族怪兽，可作为效果处理时特殊召唤的对象。
		and Duel.IsExistingTarget(c38041940.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查能否在对方场上以表侧守备表示特殊召唤1只「花种衍生物」（植物族·地·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38041941,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) end
	-- 给玩家显示选择提示，提示文字为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从己方墓地选择1只满足spfilter条件的植物族怪兽作为效果对象，并记录到当前连锁中。
	local g=Duel.SelectTarget(tp,c38041940.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将操作信息登记为‘特殊召唤’：对象为g中的1张卡，向系统宣告本次效果包含特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 将操作信息登记为‘衍生物’：将在玩家tp场上特殊召唤1只衍生物，用于后续判断。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 处理效果：若对象仍与效果相关且是植物族，先特殊召唤对象；若对方场上有空位且能特招衍生物，则在对方场上特殊召唤衍生物，并给衍生物附加不能为上级召唤而解放的限制；最后完成整个特殊召唤。
function c38041940.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁中保存的第一张对象卡（即之前选择的墓地植物族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与该效果关联、仍是植物族，并尝试将其以表侧攻击表示特殊召唤到己方场上。
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 检查对方的主要怪兽区是否存在可用空格，决定能否特殊召唤衍生物。
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查能否在对方场上以表侧守备表示特殊召唤「花种衍生物」，若不能则跳过衍生物特殊召唤。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,38041941,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then
			-- 创建「花种衍生物」的衍生物卡，卡号为38041941。
			local token=Duel.CreateToken(tp,38041941)
			-- 将衍生物以表侧守备表示特殊召唤到对方（1-tp）的怪兽区。
			Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			-- 对应效果原文：‘这衍生物不能为上级召唤而解放。’ 给衍生物附加不能作为上级召唤解放的效果。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
		end
	end
	-- 完成所有累积的特殊召唤处理，正式结算本次特殊召唤结果。
	Duel.SpecialSummonComplete()
end
