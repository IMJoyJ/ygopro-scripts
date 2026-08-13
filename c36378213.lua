--キューキューロイド
-- 效果：
-- 名字带有「机人」的怪兽从自己墓地加入手卡时，可以特殊召唤那只怪兽。
function c36378213.initial_effect(c)
	-- 名字带有「机人」的怪兽从自己墓地加入手卡时，可以特殊召唤那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36378213,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c36378213.target)
	e1:SetOperation(c36378213.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：该怪兽从持有者自己的墓地加入手卡、之前由自己控制、是名字带有「机人」的怪兽，并且能够被特殊召唤。
function c36378213.filter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsSetCard(0x16)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标的判定：从本次加入手卡的卡组中筛选满足条件的「机人」怪兽，若存在且自己场上主要怪兽区有空位则效果可发动；之后将所有加入手卡的卡设置为该连锁的对象，并设置特殊召唤的操作信息。
function c36378213.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c36378213.filter,nil,e,tp)
	-- 效果发动时进行合法性检查：存在符合条件的可特殊召唤的「机人」怪兽，且自己场上主要怪兽区有空位。
	if chk==0 then return g:GetCount()~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 将本次加入手卡的所有卡设为该效果关联的对象（使后续处理时可通过 IsRelateToEffect 验证这些卡是否仍与该效果有关）。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本连锁将进行特殊召唤，目标为筛选出的「机人」怪兽组，预计处理数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时进一步筛选：从当前加入手卡的卡组中选出仍然与效果关联、之前从自己墓地加入手卡、由自己控制、名字带「机人」且可被特殊召唤的怪兽。
function c36378213.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsSetCard(0x16)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRelateToEffect(e)
end
-- 效果处理流程：先确认可用特殊召唤区域数量；若无空位或不存在可特殊召唤对象则直接结束；若可特殊召唤的怪兽数量超过空位（或受「青眼精灵龙」限制不能同时特殊召唤2只以上）则让玩家选择相应数量的卡；最后将选中的怪兽表侧特殊召唤到己方场上。
function c36378213.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=eg:Filter(c36378213.spfilter,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 显示选择提示消息，要求玩家从候选卡中选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选中的「机人」怪兽以表侧攻击表示特殊召唤到己方场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
