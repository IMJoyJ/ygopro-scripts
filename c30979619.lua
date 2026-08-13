--SPYRAL GEAR－ビッグ・レッド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「秘旋谍」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
-- ②：装备怪兽不会被战斗破坏。
function c30979619.initial_effect(c)
	-- ①：以自己墓地1只「秘旋谍」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,30979619+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c30979619.target)
	e1:SetOperation(c30979619.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中满足「秘旋谍」字段且可以被效果特殊召唤的怪兽。
function c30979619.filter(c,e,tp)
	return c:IsSetCard(0xee) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点判定：确认指定对象是自己墓地的可特殊召唤「秘旋谍」怪兽；并检查自己怪兽区有空位且存在至少1只符合条件的对象。
function c30979619.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30979619.filter(chkc,e,tp) end
	-- 若在发动确认阶段，检查自己主要怪兽区是否有空位供特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认自己墓地存在至少1只满足条件的「秘旋谍」怪兽可以作为取对象目标。
		and Duel.IsExistingTarget(c30979619.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「秘旋谍」怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30979619.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果处理时将把对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本效果处理时把这张卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽仍与效果关联，则将对象怪兽特殊召唤；若成功，把这张卡装备给它，并设置装备对象限制，使这张卡只能装备给该怪兽。
function c30979619.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上；若特殊召唤未成功则中止处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 把这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(c30979619.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制判定：只有这张卡的效果所有者（即被①效果特殊召唤并成为装备对象的怪兽）能够装备这张卡。
function c30979619.eqlimit(e,c)
	return e:GetOwner()==c
end
