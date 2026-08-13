--早すぎた復活
-- 效果：
-- 选择自己墓地存在的1只名字带有「地缚神」的怪兽发动。选择的怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在那个回合不能攻击宣言。此外，这个效果特殊召唤的怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0。
function c39967326.initial_effect(c)
	-- 选择自己墓地存在的1只名字带有「地缚神」的怪兽发动。选择的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c39967326.target)
	e1:SetOperation(c39967326.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选墓地中名字带有「地缚神」且能够被当前效果特殊召唤的怪兽。
function c39967326.filter(c,e,tp)
	return c:IsSetCard(0x1021) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件和取对象合法性判定：自己主要怪兽区有空位，且墓地存在满足条件的「地缚神」怪兽；若为取对象时点，则校验对象仍在墓地且满足特殊召唤条件。
function c39967326.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39967326.filter(chkc,e,tp) end
	-- 检查自己场上是否拥有可用的主要怪兽区空格，没有空格则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足特殊召唤条件的名字带有「地缚神」的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c39967326.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的墓地怪兽（提示文字：‘请选择要特殊召唤的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「地缚神」怪兽，并将其设置为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c39967326.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次连锁将进行1只怪兽的特殊召唤，目标为已选择的对象组g，供相关卡牌效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若选择的对象仍与效果相关，则将其表侧表示特殊召唤到己方场上；特殊召唤成功后，为该怪兽附加‘本回合不能攻击宣言’以及‘进行战斗时对方玩家受到的战斗伤害变成0’两个效果。
function c39967326.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽（墓地中的「地缚神」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与当前效果相关（如未从墓地离开等），然后将其表侧表示特殊召唤到己方场上；特殊召唤成功则继续附加后续限制效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在那个回合不能攻击宣言。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 此外，这个效果特殊召唤的怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
