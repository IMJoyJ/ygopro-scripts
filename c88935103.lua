--貴竜の魔術師
-- 效果：
-- ←5 【灵摆】 5→
-- ①：另一边的自己的灵摆区域没有「魔术师」卡存在的场合这张卡破坏。
-- 【怪兽效果】
-- 把这张卡作为同调素材的场合，不是龙族怪兽的同调召唤不能使用，其他的同调素材有使用除「异色眼」怪兽以外的怪兽的场合，这张卡回到持有者卡组最下面。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只7星以上的「异色眼」怪兽为对象才能发动。那只怪兽的等级下降3星，这张卡特殊召唤。
function c88935103.initial_effect(c)
	-- 初始化灵摆怪兽的灵摆属性与效果。
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域没有「魔术师」卡存在的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c88935103.descon)
	c:RegisterEffect(e2)
	-- 把这张卡作为同调素材的场合，不是龙族怪兽的同调召唤不能使用
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c88935103.synlimit)
	c:RegisterEffect(e3)
	-- 其他的同调素材有使用除「异色眼」怪兽以外的怪兽的场合，这张卡回到持有者卡组最下面。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetValue(LOCATION_DECKBOT)
	e4:SetCondition(c88935103.rdcon)
	c:RegisterEffect(e4)
	-- 其他的同调素材有使用除「异色眼」怪兽以外的怪兽的场合，这张卡回到持有者卡组最下面。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c88935103.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只7星以上的「异色眼」怪兽为对象才能发动。那只怪兽的等级下降3星，这张卡特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(88935103,1))  --"特殊召唤"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e6:SetTarget(c88935103.sptg)
	e6:SetOperation(c88935103.spop)
	c:RegisterEffect(e6)
end
-- 定义灵摆效果①自我破坏的判定条件。
function c88935103.descon(e)
	-- 检查另一边的灵摆区域是否存在「魔术师」卡，若不存在则满足破坏条件。
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 定义同调素材限制：只能用于龙族怪兽的同调召唤。
function c88935103.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_DRAGON)
end
-- 定义离场重定向条件：作为同调素材且满足回到卡组最下面的条件。
function c88935103.rdcon(e)
	return e:GetHandler():IsReason(REASON_MATERIAL) and e:GetHandler():IsReason(REASON_SYNCHRO) and e:GetLabel()==1
end
-- 过滤非「异色眼」怪兽的卡片。
function c88935103.sfilter(c)
	return not c:IsSetCard(0x99)
end
-- 检查同调素材中是否存在非「异色眼」怪兽，并为重定向效果设置标记。
function c88935103.valcheck(e,c)
	if c:GetMaterial():IsExists(c88935103.sfilter,1,e:GetHandler()) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 过滤自己场上表侧表示的7星以上「异色眼」怪兽。
function c88935103.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSetCard(0x99)
end
-- 怪兽效果①的发动准备与合法性检查（Target阶段）。
function c88935103.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88935103.cfilter(chkc) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在符合条件的「异色眼」怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c88935103.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有空余的怪兽区域，且这张卡是否能特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家发送选择对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「异色眼」怪兽作为对象。
	Duel.SelectTarget(tp,c88935103.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置特殊召唤的操作信息，表明此效果包含特殊召唤1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果①的执行函数（Operation阶段）。
function c88935103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的「异色眼」怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsLevelBelow(3) then return end
	local c=e:GetHandler()
	-- 那只怪兽的等级下降3星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-3)
	tc:RegisterEffect(e1)
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡在自己场上表侧表示特殊召唤。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
