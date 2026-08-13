--チューナー・キャプチャー
-- 效果：
-- 对方对同调怪兽的同调召唤成功时才能发动。那1只作为同调素材的调整从对方墓地在自己场上特殊召唤。
function c50951359.initial_effect(c)
	-- 对方对同调怪兽的同调召唤成功时才能发动。那1只作为同调素材的调整从对方墓地在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50951359.condition)
	e1:SetTarget(c50951359.target)
	e1:SetOperation(c50951359.activate)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件：对方场上发生同调召唤，且召唤者为对方玩家时满足。
function c50951359.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonType(SUMMON_TYPE_SYNCHRO) and ep~=tp
end
-- 筛选可作为对象的卡：该卡必须是那次同调召唤的素材之一、是调整怪兽，并且能够被特殊召唤。
function c50951359.filter(c,e,tp,mg)
	return mg:IsContains(c) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象选择处理：从对方墓地选取1只满足条件的调整怪兽作为效果对象；对象合法性检查与是否存在可选对象检查均基于同调素材组进行。
function c50951359.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c50951359.filter(chkc,e,tp,eg:GetFirst():GetMaterial()) end
	-- 发动时检查：己方主要怪兽区是否留有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查：对方墓地是否至少存在1只满足条件的调整素材怪兽。
		and Duel.IsExistingTarget(c50951359.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp,eg:GetFirst():GetMaterial()) end
	-- 在让玩家选择卡片前弹出“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由己方从对方墓地选择1只符合条件的调整怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c50951359.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg:GetFirst():GetMaterial())
	-- 设置本次连锁的特殊召唤操作信息，便于其他卡效果进行时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将仍与该效果关联的对象怪兽以表侧表示特殊召唤到己方场上。
function c50951359.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
