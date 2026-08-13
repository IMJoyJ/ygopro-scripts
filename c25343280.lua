--スピリッツ・オブ・ファラオ
-- 效果：
-- 这张卡不能进行通常召唤。这张卡只能通过「第一之棺」的效果进行特殊召唤。这张卡特殊召唤成功时，可以从自己的墓地里特殊召唤至多4只2星以下的不死族通常怪兽上场。
function c25343280.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡只能通过「第一之棺」的效果进行特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，可以从自己的墓地里特殊召唤至多4只2星以下的不死族通常怪兽上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25343280,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c25343280.target)
	e2:SetOperation(c25343280.operation)
	c:RegisterEffect(e2)
end
-- 筛选条件：从墓地中选出2星以下、不死族、通常怪兽且满足当前特殊召唤条件的怪兽。
function c25343280.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsRace(RACE_ZOMBIE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：确认自己场上有空位且墓地存在可选对象；在取对象阶段让玩家从自己墓地选择1～ft张符合条件的怪兽作为效果对象。
function c25343280.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25343280.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区必须存在至少1个可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：墓地中存在至少1只满足特殊召唤条件的对象。
		and Duel.IsExistingTarget(c25343280.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 计算自己主要怪兽区的可用格数，作为本次可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1到ft张符合条件的怪兽卡，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c25343280.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 登记本次效果包含特殊召唤的操作信息，供系统在时点/相关效果判定时使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理函数：取得连锁对象并执行特殊召唤，若可用区域不足或受青眼精灵龙限制则效果不处理。
function c25343280.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象卡组，并过滤掉已与效果失去关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若自己场上可用区域少于对象数量，则本次效果不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and g:GetCount()>1 then return end
	-- 将对象卡以表侧表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
