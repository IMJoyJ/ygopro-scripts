--フルメタルフォーゼ・アルカエスト
-- 效果：
-- 「炼装」怪兽＋通常怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：对方回合1次，以场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的守备力上升这张卡的效果装备的怪兽的原本攻击力数值。
-- ③：这张卡有由「炼装」融合怪兽卡决定的融合素材怪兽装备的场合，可以把那装备卡作为那只融合怪兽的融合素材使用。
function c77693536.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为1只「炼装」怪兽和1只通常怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制只能用融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：对方回合1次，以场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77693536,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c77693536.eqcon)
	e2:SetTarget(c77693536.eqtg)
	e2:SetOperation(c77693536.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡有由「炼装」融合怪兽卡决定的融合素材怪兽装备的场合，可以把那装备卡作为那只融合怪兽的融合素材使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(c77693536.mttg)
	e3:SetValue(c77693536.mtval)
	c:RegisterEffect(e3)
end
-- 装备效果的发动条件函数
function c77693536.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤场上的表侧表示效果怪兽，且该怪兽可以改变控制权（若是对方怪兽）
function c77693536.eqfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
		and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- 装备效果的发动准备（Target）函数
function c77693536.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c77693536.eqfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 判定自身魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定场上是否存在除自身以外可以作为对象的表侧表示效果怪兽
		and Duel.IsExistingTarget(c77693536.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上的表侧表示效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77693536.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
	-- 设置效果处理信息为装备该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备效果的执行（Operation）函数
function c77693536.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时魔法与陷阱区域没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)) then return end
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
	if not Duel.Equip(tp,tc,c) then return end
	-- ②：这张卡的守备力上升这张卡的效果装备的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- 那只效果怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c77693536.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
-- 限制装备卡只能装备给这张卡
function c77693536.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤出装备在这张卡上且原本是怪兽的卡片，使其可以作为融合素材
function c77693536.mttg(e,c)
	return c:GetEquipTarget()==e:GetHandler() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 限制该装备卡只能作为「炼装」融合怪兽的融合素材
function c77693536.mtval(e,c)
	if not c then return false end
	return c:IsSetCard(0xe1)
end
