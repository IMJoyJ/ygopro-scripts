--青き眼の護人
-- 效果：
-- 「青色眼睛的护人」的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只光属性·1星调整特殊召唤。
-- ②：以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从手卡把1只「青眼」怪兽特殊召唤。
function c72855441.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只光属性·1星调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c72855441.sptg)
	e1:SetOperation(c72855441.spop)
	c:RegisterEffect(e1)
	-- 「青色眼睛的护人」的②的效果1回合只能使用1次。②：以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从手卡把1只「青眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,72855441)
	e2:SetTarget(c72855441.gvtg)
	e2:SetOperation(c72855441.gvop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中满足“光属性·1星调整”且能特殊召唤的卡片
function c72855441.spfilter1(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及手卡中是否存在可特殊召唤的“光属性·1星调整”
function c72855441.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只满足条件的光属性·1星调整怪兽
		and Duel.IsExistingMatchingCard(c72855441.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的执行：从手卡选择1只光属性·1星调整特殊召唤
function c72855441.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的光属性·1星调整怪兽
	local g=Duel.SelectMatchingCard(tp,c72855441.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示、可送去墓地的效果怪兽（若场上无空位，则必须选择主要怪兽区域的怪兽以腾出空位）
function c72855441.gvfilter(c,ft)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave() and (ft>0 or c:GetSequence()<5)
end
-- 过滤手卡中满足“「青眼」怪兽”且能特殊召唤的卡片
function c72855441.spfilter2(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：选择自己场上1只效果怪兽作为对象，并检查手卡中是否存在可特殊召唤的“「青眼」怪兽”
function c72855441.gvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c72855441.gvfilter(chkc,ft) end
	-- 检查是否存在可作为对象送去墓地的效果怪兽（若空格数为0，则必须选择场上的怪兽以腾出格子）
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c72855441.gvfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 并且检查手卡中是否存在至少1只满足条件的「青眼」怪兽
		and Duel.IsExistingMatchingCard(c72855441.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己场上1只效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72855441.gvfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置连锁处理中的操作信息：将选中的对象怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的执行：将作为对象的怪兽送去墓地，并从手卡特殊召唤1只「青眼」怪兽
function c72855441.gvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽因效果送去墓地，并确认其已成功到达墓地
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
			-- 并且检查自己场上是否有可用的怪兽区域空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且检查手卡中是否存在至少1只满足条件的「青眼」怪兽
			and Duel.IsExistingMatchingCard(c72855441.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从手卡选择1只满足条件的「青眼」怪兽
			local g=Duel.SelectMatchingCard(tp,c72855441.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的「青眼」怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
