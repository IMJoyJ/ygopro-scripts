--取捨蘇生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地3只怪兽为对象才能发动。对方从作为对象的怪兽之中选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽全部除外。
function c50213848.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地3只怪兽为对象才能发动。对方从作为对象的怪兽之中选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50213848+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c50213848.target)
	e1:SetOperation(c50213848.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：判定自己墓地的怪兽是否既能够通过当前效果被特殊召唤（满足召唤条件与苏生限制），又能够被除外。
function c50213848.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAbleToRemove()
end
-- 效果发动的目标与条件检查部分：取对象时要求对象在自己墓地且满足筛选；发动条件检查时需自己主要怪兽区有空位且墓地存在至少3只满足条件的对象。
function c50213848.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50213848.filter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽格子（用于后续特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少3只满足筛选条件且能成为效果对象的怪兽。
		and Duel.IsExistingTarget(c50213848.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 给发动者显示“请选择要特殊召唤的卡”的提示，实际上用于从墓地选择3只对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动者从自己墓地选择3只满足条件的怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c50213848.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 登记操作信息：该连锁后续将进行1只怪兽的特殊召唤，供其他卡片的发动条件检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：从对象中筛选仍与效果相关且可特殊召唤的怪兽；若无怪兽或自己场上无空格则效果不适用；由对方选择1只怪兽特殊召唤到自己场上，其余全部除外。
function c50213848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁登记的对象卡组，过滤掉已与效果失去关联的卡，以及已无法被当前效果特殊召唤的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	-- 若过滤后没有可特殊召唤的怪兽，或自己场上没有空出的主要怪兽区，则终止本次效果处理。
	if g:GetCount()==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给对手显示“请选择要特殊召唤的卡”的提示，由对方从对象怪兽中选择1只要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	-- 将对方选中的那只怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	g:RemoveCard(tc)
	-- 将剩余的作为对象的怪兽全部以表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
