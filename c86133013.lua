--レベル・レジストウォール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，以那1只怪兽为对象才能发动。等级合计直到变成和那只怪兽相同为止，从卡组选怪兽任意数量守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c86133013.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽被战斗或者对方的效果破坏的场合，以那1只怪兽为对象才能发动。等级合计直到变成和那只怪兽相同为止，从卡组选怪兽任意数量守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,86133013+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c86133013.target)
	e1:SetOperation(c86133013.activate)
	c:RegisterEffect(e1)
end
-- 过滤符合发动条件的被破坏怪兽：必须是自己场上因战斗或对方效果破坏并送去墓地或除外的、等级大于0且可以作为效果对象的怪兽，且卡组中存在等级合计等于该怪兽等级的怪兽组合
function c86133013.tgfilter(c,e,tp,rp,g,ft)
	local lv=c:GetLevel()
	if not ((c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		and lv>0) then return false end
	local sg=g:Filter(Card.IsLevelBelow,nil,lv)
	-- 设置卡片选择的辅助检查函数，限制选择的怪兽等级合计不能超过目标怪兽的等级
	aux.GCheckAdditional=c86133013.gcheck(lv)
	local res=sg:CheckSubGroup(c86133013.fgoal,1,ft,lv)
	-- 清除卡片选择的辅助检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 辅助检查函数：判断当前已选怪兽的等级合计是否小于或等于目标怪兽的等级
function c86133013.gcheck(lv)
	return	function(sg)
				return sg:GetSum(Card.GetLevel)<=lv
			end
end
-- 目标检查函数：判断所选怪兽的等级合计是否刚好等于目标怪兽的等级
function c86133013.fgoal(sg,lv)
	return sg:GetSum(Card.GetLevel)==lv
end
-- 过滤卡组中可以表侧守备表示特殊召唤的怪兽
function c86133013.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的准备与合法性检测（包括检测怪兽区域空位数、青眼精灵龙的影响、寻找符合条件的被破坏怪兽作为对象，并设置特殊召唤的操作信息）
function c86133013.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有可以特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c86133013.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chkc then return eg:IsContains(chkc) and c86133013.tgfilter(chkc,e,tp,rp,g,ft) end
	if chk==0 then return ft>0 and eg:IsExists(c86133013.tgfilter,1,nil,e,tp,rp,g,ft) end
	local tg
	if #eg==1 then
		tg=eg
	else
		-- 提示玩家选择作为效果对象的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tg=eg:FilterSelect(tp,c86133013.tgfilter,1,1,nil,e,tp,rp,g,ft)
	end
	-- 将选择的怪兽设置为效果处理的对象
	Duel.SetTargetCard(tg)
	-- 设置当前连锁的操作信息为“从卡组特殊召唤怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行（获取对象怪兽等级，从卡组选择等级合计等于该等级的怪兽守备表示特殊召唤，并无效化它们的效果）
function c86133013.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的那1只被破坏的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有可以特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c86133013.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local lv=tc:GetLevel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置卡片选择的辅助检查函数，限制选择的怪兽等级合计不能超过目标怪兽的等级
	aux.GCheckAdditional=c86133013.gcheck(lv)
	local sg=g:SelectSubGroup(tp,c86133013.fgoal,false,1,ft,lv)
	-- 清除卡片选择的辅助检查函数
	aux.GCheckAdditional=nil
	if not sg then return end
	local tc=sg:GetFirst()
	while tc do
		-- 将选定的怪兽以表侧守备表示逐步特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
