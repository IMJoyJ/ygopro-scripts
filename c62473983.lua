--墓守の長
-- 效果：
-- 这张卡在自己场上只能存在1张。只要这张卡在场上存在，自己的墓地不受「王家长眠之谷」效果的影响。这张卡祭品召唤成功的场合，可以从自己的墓地中特殊召唤1张名称中带有「守墓」的怪兽卡上场。
function c62473983.initial_effect(c)
	c:SetUniqueOnField(1,0,62473983)
	-- 只要这张卡在场上存在，自己的墓地不受「王家长眠之谷」效果的影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_NECRO_VALLEY_IM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	-- 这张卡祭品召唤成功的场合，可以从自己的墓地中特殊召唤1张名称中带有「守墓」的怪兽卡上场。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c62473983.spcon)
	e2:SetTarget(c62473983.sptg)
	e2:SetOperation(c62473983.spop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否通过上级召唤（祭品召唤）成功
function c62473983.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤自己墓地中可以特殊召唤的「守墓」怪兽
function c62473983.filter(c,e,tp)
	return c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件判定与目标选择
function c62473983.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c62473983.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的「守墓」怪兽
		and Duel.IsExistingTarget(c62473983.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1张符合条件的「守墓」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62473983.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置在效果处理时将特殊召唤该卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理
function c62473983.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的唯一效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
