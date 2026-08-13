--絶火の祆現
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只4星以下的「大贤者」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己的魔法与陷阱区域的「大贤者」卡被对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c327051.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己墓地1只4星以下的「大贤者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,327051)
	e1:SetTarget(c327051.target)
	e1:SetOperation(c327051.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己的魔法与陷阱区域的「大贤者」卡被对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,327052)
	e2:SetTarget(c327051.reptg)
	e2:SetValue(c327051.repval)
	c:RegisterEffect(e2)
end
-- 筛选满足特殊召唤条件的卡：4星以下、拥有「大贤者」字段、且可以特殊召唤的怪兽。
function c327051.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x150) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象效果的发动判定：确认对象卡合法；并在发动时检查自己有可用怪兽区且墓地存在符合条件的「大贤者」怪兽。
function c327051.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c327051.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空格，确保能够特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足filter条件的「大贤者」怪兽可作为对象。
		and Duel.IsExistingTarget(c327051.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给操作玩家发出选择提示，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从自己墓地选择1只满足filter条件的「大贤者」怪兽作为效果对象，并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c327051.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将当前连锁的操作信息登记为特殊召唤，对象为已选择的怪兽g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将所选对象怪兽特殊召唤到自己场上；若对象仍与该效果关联则执行。
function c327051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断一张卡是否满足②的代替破坏条件：己方主要魔陷区表侧表示的「大贤者」卡，因对方效果被破坏且不是被代替破坏。
function c327051.repfilter(c,tp)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x150) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动条件与处理：自己墓地的此卡可除外，且本次破坏的卡中有符合repfilter的卡时，询问后除外自身代替破坏。
function c327051.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c327051.repfilter,1,nil,tp) end
	-- 询问当前玩家是否发动本卡的代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将墓地的这张「绝火的祆现」以表侧表示除外，作为被破坏的「大贤者」卡的代替。
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 代替破坏判定回调：判断被破坏的卡c是否为符合条件的「大贤者」卡，决定是否允许代替破坏。
function c327051.repval(e,c)
	return c327051.repfilter(c,e:GetHandlerPlayer())
end
