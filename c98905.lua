--光波分光
-- 效果：
-- ①：自己场上的持有超量素材的「光波」超量怪兽被战斗或者对方的效果破坏送去自己墓地的场合，以那1只怪兽为对象才能发动。那只怪兽从墓地特殊召唤，把1只和那只怪兽同名的超量怪兽从额外卡组特殊召唤。
function c98905.initial_effect(c)
	-- ①：自己场上的持有超量素材的「光波」超量怪兽被战斗或者对方的效果破坏送去自己墓地的场合，以那1只怪兽为对象才能发动。那只怪兽从墓地特殊召唤，把1只和那只怪兽同名的超量怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c98905.target)
	e1:SetOperation(c98905.activate)
	c:RegisterEffect(e1)
end
-- 过滤在场上持有超量素材、因战斗或对方效果破坏送去自己墓地、可以作为效果对象且可以特殊召唤，并且额外卡组存在同名超量怪兽的「光波」超量怪兽
function c98905.filter(c,e,tp)
	return c:GetPreviousOverlayCountOnField()~=0 and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
		and c:IsReason(REASON_DESTROY) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在至少1只可以特殊召唤的同名超量怪兽
		and Duel.IsExistingMatchingCard(c98905.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 过滤额外卡组中同名、可特殊召唤且有可用怪兽区域出场的超量怪兽
function c98905.spfilter(c,e,tp,cd)
	-- 检查该卡是否为超量怪兽、卡名是否相同、是否可以特殊召唤，以及额外卡组怪兽出场是否有可用区域
	return c:IsType(TYPE_XYZ) and c:IsCode(cd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的对象选择与可行性检查（包含青眼精灵龙的限制检测、怪兽区域空格检测以及是否存在满足条件的被破坏怪兽）
function c98905.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c98905.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c98905.filter,1,nil,e,tp) end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c98905.filter,1,1,nil,e,tp)
	-- 将选择的被破坏怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息，表明此效果包含特殊召唤1张目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：先将墓地的目标怪兽特殊召唤，若成功且满足条件，再从额外卡组特殊召唤1只同名超量怪兽
function c98905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时选择的作为效果对象的那1只怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只与目标怪兽同名的超量怪兽
		local g=Duel.SelectMatchingCard(tp,c98905.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选择的额外卡组的同名超量怪兽以表侧表示特殊召唤（分步处理）
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 完成所有分步特殊召唤的处理，使怪兽正式出场
	Duel.SpecialSummonComplete()
end
