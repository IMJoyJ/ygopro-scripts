--サイバネット・カスケード
-- 效果：
-- ①：自己对连接怪兽的连接召唤成功的场合，以那1只作为连接素材的自己墓地的怪兽为对象才能发动。那只怪兽特殊召唤。
function c4433488.initial_effect(c)
	-- ①：自己对连接怪兽的连接召唤成功的场合，以那1只作为连接素材的自己墓地的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c4433488.target)
	e1:SetOperation(c4433488.activate)
	c:RegisterEffect(e1)
end
-- 过滤连接怪兽：必须为连接怪兽、通过连接召唤出场且召唤玩家是这张卡的发动者（即自己）。
function c4433488.cfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 特殊召唤候选的过滤：候选怪兽必须能被这张卡的效果以表侧表示特殊召唤，并且是连接召唤成功时所用素材中的一张。
function c4433488.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g and g:IsContains(c)
end
-- 发动时点判定与取对象选择：从这次连接召唤成功时的诱发事件中取出满足条件的连接怪兽作为连接素材来源，并检查能否选择自己墓地的对应素材进行特殊召唤。
function c4433488.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lc=eg:Filter(c4433488.cfilter,nil,tp):GetFirst()
	if chkc then return chkc:IsControler(tp) and c4433488.spfilter(chkc,e,tp,lc:GetMaterial()) end
	-- 合法性检查：存在刚成功连接召唤的连接怪兽，且自己主要怪兽区有空位可以特殊召唤。
	if chk==0 then return lc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查：在自己墓地存在至少1张属于该连接怪兽连接素材且可以被特殊召唤的怪兽。
		and Duel.IsExistingTarget(c4433488.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lc:GetMaterial()) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，用于选择对象的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的满足条件的素材中选1张作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c4433488.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lc:GetMaterial())
	-- 将本次连锁要进行的处理登记为特殊召唤1只怪兽，供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：取出之前选择的对象，若该卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c4433488.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时选择的取对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击/守备表示（默认表侧表示）特殊召唤到自己场上，且不检查召唤条件、不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
