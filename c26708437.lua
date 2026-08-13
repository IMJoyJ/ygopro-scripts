--エクシーズ・リボーン
-- 效果：
-- ①：以自己墓地1只超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡在下面重叠作为超量素材。
function c26708437.initial_effect(c)
	-- ①：以自己墓地1只超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡在下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c26708437.target)
	e1:SetOperation(c26708437.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己墓地中满足条件的超量怪兽，要求为超量怪兽且能被当前效果特殊召唤（满足苏生限制）。
function c26708437.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：先校验取对象时目标的合法性，再在chk==0时确认发动条件：本卡为魔法卡发动、自己怪兽区有空位、本卡可作为超量素材，且墓地存在可特殊召唤的超量怪兽。
function c26708437.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26708437.filter(chkc,e,tp) end
	-- 发动条件判断：确认当前效果是以魔法卡形式发动，且自己场上主要怪兽区有空位可供特殊召唤。
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanOverlay()
		-- 发动条件追加：确认自己墓地存在至少1只满足特殊召唤条件的超量怪兽且可作为效果对象。
		and Duel.IsExistingTarget(c26708437.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的超量怪兽作为效果对象，并自动与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,c26708437.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本连锁将执行特殊召唤，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象超量怪兽特殊召唤成功，且这张魔法卡仍与效果关联并可作为超量素材，则先取消其发动后送去墓地的状态，再将其叠放在该怪兽下方作为超量素材。
function c26708437.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联、特殊召唤成功，且本卡仍在场上且可作为超量素材；条件满足时继续执行叠放。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		c:CancelToGrave()
		-- 将这张卡叠放到该超量怪兽下方，作为超量素材。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
