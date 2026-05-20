--月影龍クイラ
-- 效果：
-- 「苏帕伊」＋调整以外的怪兽1只以上
-- ①：这张卡被选择作为攻击对象的场合发动。自己基本分回复攻击怪兽的攻击力一半的数值。
-- ②：场上的这张卡被破坏的场合，以自己墓地1只「太阳龙 因蒂」为对象才能发动。那只怪兽特殊召唤。
function c66818682.initial_effect(c)
	-- 将「苏帕伊」放入该怪兽的素材卡片代码列表中，用于辅助检索或召唤判定
	aux.AddMaterialCodeList(c,78552773)
	-- 添加同调召唤手续：以「苏帕伊」为调整，加上1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,78552773),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡被选择作为攻击对象的场合发动。自己基本分回复攻击怪兽的攻击力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66818682,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c66818682.rectg)
	e1:SetOperation(c66818682.recop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏的场合，以自己墓地1只「太阳龙 因蒂」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66818682,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c66818682.spcon)
	e2:SetTarget(c66818682.sptg)
	e2:SetOperation(c66818682.spop)
	c:RegisterEffect(e2)
end
-- 效果①（回复LP）的发动准备与目标确认函数
function c66818682.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取本次战斗中进行攻击的怪兽
	local tc=Duel.GetAttacker()
	tc:CreateEffectRelation(e)
	-- 设置当前连锁的操作信息为：玩家回复攻击怪兽攻击力一半（向上取整）的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(tc:GetAttack()/2))
end
-- 效果①（回复LP）的效果处理函数
function c66818682.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使玩家回复攻击怪兽攻击力一半（向上取整）的生命值
		Duel.Recover(tp,math.ceil(tc:GetAttack()/2),REASON_EFFECT)
	end
end
-- 效果②（特殊召唤）的发动条件：这张卡原本在场上存在
function c66818682.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤墓地中可以特殊召唤的「太阳龙 因蒂」的条件函数
function c66818682.spfilter(c,e,tp)
	return c:IsCode(39823987) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特殊召唤）的发动准备与取对象判定
function c66818682.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66818682.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「太阳龙 因蒂」
		and Duel.IsExistingTarget(c66818682.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「太阳龙 因蒂」作为效果的对象
	local g=Duel.SelectTarget(tp,c66818682.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为：特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（特殊召唤）的效果处理函数
function c66818682.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
