--ヴェンデット・リボーン
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽解放，把持有和那个原本等级相同等级的1只「复仇死者衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是「复仇死者」怪兽不能召唤·特殊召唤。
function c30650147.initial_effect(c)
	-- 效果原文内容：①：以对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c30650147.target)
	e1:SetOperation(c30650147.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断目标怪兽是否满足解放条件并可特殊召唤衍生物
function c30650147.filter(c,tp)
	return c:IsFaceup() and c:GetOriginalLevel()>0 and c:IsReleasableByEffect()
		-- 规则层面操作：检查玩家是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,30650148,0x106,TYPES_TOKEN_MONSTER,0,0,c:GetOriginalLevel(),RACE_ZOMBIE,ATTRIBUTE_DARK)
end
-- 效果原文内容：那只怪兽解放，把持有和那个原本等级相同等级的1只「复仇死者衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。
function c30650147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c30650147.filter(chkc,tp) end
	-- 规则层面操作：检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：确认场上是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c30650147.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 规则层面操作：提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 规则层面操作：选择目标怪兽作为解放对象
	Duel.SelectTarget(tp,c30650147.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 规则层面操作：设置连锁操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 规则层面操作：设置连锁操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果原文内容：只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是「复仇死者」怪兽不能召唤·特殊召唤。
function c30650147.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面操作：判断目标怪兽是否仍然有效且能被解放并有空位进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 规则层面操作：创建指定编号的衍生物
		local token=Duel.CreateToken(tp,30650148)
		-- 规则层面操作：将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文内容：只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是「复仇死者」怪兽不能召唤·特殊召唤。
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
		-- 效果原文内容：只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是「复仇死者」怪兽不能召唤·特殊召唤。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetOriginalLevel())
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e3,true)
		-- 规则层面操作：完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 规则层面操作：限制非复仇死者怪兽的召唤与特殊召唤
function c30650147.splimit(e,c)
	return not c:IsSetCard(0x106)
end
