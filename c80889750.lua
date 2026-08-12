--デストーイ・サーベル・タイガー
-- 效果：
-- 「魔玩具」融合怪兽＋「毛绒动物」怪兽或者「锋利小鬼」怪兽1只以上
-- ①：这张卡融合召唤成功时，以自己墓地1只「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的「魔玩具」怪兽的攻击力上升400。
-- ③：怪兽3只以上为素材作融合召唤的这张卡不会被战斗·效果破坏。
function c80889750.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤的手续：以1只「魔玩具」融合怪兽和1只以上的「毛绒动物」怪兽或「锋利小鬼」怪兽为融合素材
	aux.AddFusionProcFunFunRep(c,c80889750.mfilter1,c80889750.mfilter2,1,127,true)
	-- ①：这张卡融合召唤成功时，以自己墓地1只「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c80889750.spcon)
	e2:SetTarget(c80889750.sptg)
	e2:SetOperation(c80889750.spop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「魔玩具」怪兽的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤受攻击力上升效果影响的卡，条件为自己场上的「魔玩具」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xad))
	e3:SetValue(400)
	c:RegisterEffect(e3)
	-- ③：怪兽3只以上为素材作融合召唤的这张卡不会被战斗·效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c80889750.indcon)
	e4:SetOperation(c80889750.indop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件1：字段为「魔玩具」且是融合怪兽
function c80889750.mfilter1(c)
	return c:IsFusionSetCard(0xad) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤条件2：字段为「毛绒动物」或「锋利小鬼」的怪兽
function c80889750.mfilter2(c)
	return c:IsFusionSetCard(0xa9,0xc3)
end
-- 效果①的发动条件：这张卡融合召唤成功
function c80889750.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的特殊召唤对象过滤：自己墓地中可以特殊召唤的「魔玩具」怪兽
function c80889750.spfilter(c,e,tp)
	return c:IsSetCard(0xad) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）：检查怪兽区域空位及墓地中是否存在合法的「魔玩具」怪兽，并进行取对象操作
function c80889750.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80889750.spfilter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以特殊召唤的「魔玩具」怪兽
		and Duel.IsExistingTarget(c80889750.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只「魔玩具」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80889750.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表示该效果包含特殊召唤操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（Operation）：将选中的墓地怪兽特殊召唤
function c80889750.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的适用条件：这张卡是融合召唤成功，且使用的融合素材怪兽数量在3只以上
function c80889750.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()>=3
end
-- 效果③的效果处理：为自身添加“不会被战斗破坏”和“不会被效果破坏”的抗性
function c80889750.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 不会被战斗...破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(80889750,0))  --"不会被战斗·效果破坏"
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	c:RegisterEffect(e2)
end
