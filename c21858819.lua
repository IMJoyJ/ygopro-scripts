--No.XX インフィニティ・ダークホープ
-- 效果：
-- 10星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽被战斗破坏送去墓地时，把这张卡1个超量素材取除，以那1只怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
-- ②：以这张卡以外的自己场上1只特殊召唤的表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c21858819.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为10、数量为2只以上的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,10,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：自己或者对方的怪兽被战斗破坏送去墓地时，把这张卡1个超量素材取除，以那1只怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21858819,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21858819)
	e1:SetCost(c21858819.cost)
	e1:SetTarget(c21858819.target)
	e1:SetOperation(c21858819.activate)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的自己场上1只特殊召唤的表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21858819,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21858820)
	e2:SetTarget(c21858819.rectg)
	e2:SetOperation(c21858819.recop)
	c:RegisterEffect(e2)
end
-- 支付1个超量素材作为cost
function c21858819.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的被战斗破坏送入墓地的怪兽，可作为效果对象且能特殊召唤
function c21858819.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标为符合条件的被战斗破坏怪兽，并准备特殊召唤
function c21858819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c21858819.filter,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		return g:GetCount()~=0
	end
	-- 设置当前连锁的效果对象为指定怪兽
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetLabelObject(),1,0,0)
end
-- 执行效果，将目标怪兽特殊召唤到场上
function c21858819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤满足条件的特殊召唤的表侧表示怪兽
function c21858819.recfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置效果目标为符合条件的特殊召唤怪兽，并准备回复LP
function c21858819.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21858819.recfilter(chkc) end
	-- 检查是否存在符合条件的特殊召唤怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c21858819.recfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的特殊召唤怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c21858819.recfilter,tp,LOCATION_MZONE,0,1,1,c)
	-- 设置操作信息为回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetBaseAttack())
end
-- 执行效果，回复LP
function c21858819.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetBaseAttack()>0 then
		-- 使玩家回复目标怪兽攻击力数值的LP
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
