--グレイドル・ドラゴン
-- 效果：
-- 水族调整＋调整以外的怪兽1只以上
-- 「灰篮龙」的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功时，以最多有那些作为同调素材的水属性怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，以这张卡以外的自己墓地1只水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c52145422.initial_effect(c)
	-- 设置同调召唤手续：需要1只水族调整怪兽加上1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以最多有那些作为同调素材的水属性怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,52145422)
	e1:SetCondition(c52145422.descon)
	e1:SetTarget(c52145422.destg)
	e1:SetOperation(c52145422.desop)
	c:RegisterEffect(e1)
	-- 检查同调素材中水属性怪兽的数量，用于确定效果①可破坏的卡片数量上限
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c52145422.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，以这张卡以外的自己墓地1只水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,52145423)
	e3:SetCondition(c52145422.spcon)
	e3:SetTarget(c52145422.sptg)
	e3:SetOperation(c52145422.spop)
	c:RegisterEffect(e3)
end
-- 统计作为同调素材的水属性怪兽数量，并将该数值存储到效果标签中供后续使用
function c52145422.valcheck(e,c)
	local ct=e:GetHandler():GetMaterial():FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)
	e:GetLabelObject():SetLabel(ct)
end
-- 检查这张卡是否通过同调召唤方式特殊召唤成功
function c52145422.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 选择对方场上最多有作为同调素材的水属性怪兽数量的卡作为破坏对象，并设置操作信息
function c52145422.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ct=e:GetLabel()
	-- 检查水属性素材数量大于0且对方场上存在可选择的卡片
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1到ct张卡作为效果的对象，ct为素材中水属性怪兽的数量
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息，声明要破坏选择的对象卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理破坏效果：获取效果对象并破坏仍与效果关联的卡片
function c52145422.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组，并筛选出仍与当前效果有关联的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因破坏选中的对象卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 检查这张卡是否因战斗或效果原因被破坏并送去墓地
function c52145422.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 筛选条件：水属性且可以被特殊召唤的怪兽
function c52145422.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择这张卡以外的自己墓地1只水属性怪兽作为特殊召唤对象，检查可用区域和目标存在性
function c52145422.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52145422.filter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在这张卡以外的水属性怪兽可作为特殊召唤对象
		and Duel.IsExistingTarget(c52145422.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择墓地中1张这张卡以外的水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c52145422.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置当前连锁的操作信息，声明要特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤选择的怪兽，并为其添加效果无效化的永续效果
function c52145422.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的对象怪兽（这张卡以外的墓地水属性怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查对象仍与效果关联，并开始特殊召唤流程将其以表侧表示特殊召唤到场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。（使怪兽的永续效果无效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。（使怪兽的诱发效果无效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程，将怪兽正式放置到场上
	Duel.SpecialSummonComplete()
end
