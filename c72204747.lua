--オーバー・デステニー
-- 效果：
-- ①：以自己墓地1只「命运英雄」怪兽为对象才能发动。把持有那只怪兽的等级一半以下的等级的1只「命运英雄」怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c72204747.initial_effect(c)
	-- ①：以自己墓地1只「命运英雄」怪兽为对象才能发动。把持有那只怪兽的等级一半以下的等级的1只「命运英雄」怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c72204747.target)
	e1:SetOperation(c72204747.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中等级一半以下有对应「命运英雄」怪兽存在于卡组的「命运英雄」怪兽
function c72204747.filter1(c,e,sp)
	local lv=math.floor(c:GetLevel()/2)
	return lv>0 and c:IsSetCard(0xc008)
		-- 检查卡组中是否存在等级在指定值以下且可以特殊召唤的「命运英雄」怪兽
		and Duel.IsExistingMatchingCard(c72204747.filter2,sp,LOCATION_DECK,0,1,nil,lv,e,sp)
end
-- 过滤卡组中等级在指定值以下且可以特殊召唤的「命运英雄」怪兽
function c72204747.filter2(c,lv,e,sp)
	return c:IsLevelBelow(lv) and c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的对象选择与合法性检查
function c72204747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72204747.filter1(chkc,e,tp) end
	-- 检查自己墓地是否存在满足条件的「命运英雄」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c72204747.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择作为对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(72204747,0))  --"请选择1只名字带有「命运英雄」的怪兽"
	-- 选择自己墓地1只「命运英雄」怪兽作为对象
	Duel.SelectTarget(tp,c72204747.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤卡组怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，特殊召唤卡组中等级一半以下的「命运英雄」怪兽，并注册结束阶段破坏的效果
function c72204747.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只等级在对象怪兽等级一半以下的「命运英雄」怪兽
	local cg=Duel.SelectMatchingCard(tp,c72204747.filter2,tp,LOCATION_DECK,0,1,1,nil,math.floor(tc:GetLevel()/2),e,tp)
	if cg:GetCount()==0 then return end
	local sc=cg:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤，若成功则执行后续处理
	if Duel.SpecialSummon(cg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		sc:RegisterFlagEffect(72204747,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(sc)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(c72204747.descon)
		e1:SetOperation(c72204747.desop)
		-- 注册在回合结束阶段触发的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查被特殊召唤的怪兽是否仍带有对应的标记，以确定是否在结束阶段破坏
function c72204747.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(72204747)==e:GetLabel()
end
-- 结束阶段破坏该怪兽的效果处理
function c72204747.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
