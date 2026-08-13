--ヴェンデット・リボーン
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽解放，把持有和那个原本等级相同等级的1只「复仇死者衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是「复仇死者」怪兽不能召唤·特殊召唤。
function c30650147.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c30650147.target)
	e1:SetOperation(c30650147.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的对方表侧怪兽：须表侧表示、原等级大于0、可被效果解放，且当前玩家能特殊召唤对应等级的复仇死者衍生物。
function c30650147.filter(c,tp)
	return c:IsFaceup() and c:GetOriginalLevel()>0 and c:IsReleasableByEffect()
		-- 检查当前玩家是否能够特殊召唤卡号30650148的衍生物（不死族·暗·攻/守0，含「复仇死者」字段），其等级等于对象怪兽的原本等级。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,30650148,0x106,TYPES_TOKEN_MONSTER,0,0,c:GetOriginalLevel(),RACE_ZOMBIE,ATTRIBUTE_DARK)
end
-- 效果发动时的对象选择与合法性检查：chkc用于校验指定对象为对方场上表侧且满足filter；chk==0时检查我方主怪兽区有空位且对方场上有满足条件的怪兽。
function c30650147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c30650147.filter(chkc,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空格，以确定能否特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只满足filter条件且可成为效果对象的表侧表示怪兽。
		and Duel.IsExistingTarget(c30650147.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向操作玩家显示提示信息，要求选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从对方场上选择1只满足条件的表侧表示怪兽作为效果的对象（该卡将成为连锁处理时的对象）。
	Duel.SelectTarget(tp,c30650147.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 登记本次效果会生成衍生物的操作信息，供其他效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记本次效果会进行特殊召唤的操作信息，供其他效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍与效果相关则将其解放，并在自己场上还有空位时特殊召唤1只「复仇死者衍生物」，随后给该衍生物附加自肃效果（只能召唤/特殊召唤「复仇死者」怪兽）并设定等级为对象怪兽的原本等级，最后完成特殊召唤。
function c30650147.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽仍与效果关联，并通过效果将其解放；同时确认自己场上有空格，才继续特殊召唤衍生物。
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 生成1只由当前玩家控制的「复仇死者衍生物」（卡号30650148）的Token。
		local token=Duel.CreateToken(tp,30650148)
		-- 将衍生物以表侧表示特殊召唤到自己场上（特殊召唤处理的第一步），不检查召唤条件与苏生限制。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是「复仇死者」怪兽不能召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c30650147.splimit)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		token:RegisterEffect(e2,true)
		-- 把持有和那个原本等级相同等级的1只「复仇死者衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetOriginalLevel())
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e3,true)
		-- 完成特殊召唤处理，宣告这次特殊召唤成功并触发相关时点。
		Duel.SpecialSummonComplete()
	end
end
-- 自肃效果的判定条件：如果尝试召唤/特殊召唤的怪兽不是「复仇死者」（setcode 0x106）怪兽，则不允许。
function c30650147.splimit(e,c)
	return not c:IsSetCard(0x106)
end
