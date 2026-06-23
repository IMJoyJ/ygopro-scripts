--絶火の祆現
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只4星以下的「大贤者」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己的魔法与陷阱区域的「大贤者」卡被对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c327051.initial_effect(c)
	-- ①：以自己墓地1只4星以下的「大贤者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,327051)
	e1:SetTarget(c327051.target)
	e1:SetOperation(c327051.activate)
	c:RegisterEffect(e1)
	-- ②：自己的魔法与陷阱区域的「大贤者」卡被对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,327052)
	e2:SetTarget(c327051.reptg)
	e2:SetValue(c327051.repval)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地「大贤者」怪兽（4星以下且可特殊召唤）
function c327051.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x150) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件（是否有符合条件的墓地目标）
function c327051.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c327051.filter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的「大贤者」怪兽
		and Duel.IsExistingTarget(c327051.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地「大贤者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c327051.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理①效果的发动，将选中的怪兽特殊召唤
function c327051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的魔法与陷阱区域的「大贤者」卡（被对方效果破坏且未被代替破坏）
function c327051.repfilter(c,tp)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x150) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动②效果（是否满足代替破坏条件）
function c327051.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c327051.repfilter,1,nil,tp) end
	-- 询问玩家是否发动②效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将自身从墓地除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 返回代替破坏的目标卡是否符合条件
function c327051.repval(e,c)
	return c327051.repfilter(c,e:GetHandlerPlayer())
end
