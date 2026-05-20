--アメイズメント・スペシャルショー
-- 效果：
-- ①：自己场上的「惊乐」怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，以那1只自己的「惊乐」怪兽为对象才能发动。那只怪兽回到持有者手卡。那之后，可以从手卡把1只「惊乐」怪兽特殊召唤。
function c6374519.initial_effect(c)
	-- ①：自己场上的「惊乐」怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，以那1只自己的「惊乐」怪兽为对象才能发动。那只怪兽回到持有者手卡。那之后，可以从手卡把1只「惊乐」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6374519,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c6374519.spcon)
	e1:SetTarget(c6374519.sptg)
	e1:SetOperation(c6374519.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足“表侧表示、属于「惊乐」系列、在怪兽区域、由自己控制、可以成为效果对象、且能回到手卡”条件的卡片
function c6374519.thfilter(c,tp,e)
	return c:IsFaceup() and c:IsSetCard(0x15b) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 检查发动条件：对方发动了取对象的效果，且该效果的对象中存在自己场上满足条件的「惊乐」怪兽
function c6374519.spcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被选为对象的所有卡片
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(c6374519.thfilter,1,nil,tp,e)
end
-- 效果发动的目标选择与处理准备：在对方效果的对象中，选择1只自己的「惊乐」怪兽作为本效果的对象，并声明回手牌的操作信息
function c6374519.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前连锁中被选为对象的所有卡片
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if chkc then return eg:IsContains(chkc) and c6374519.thfilter(chkc,tp,e) end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:FilterSelect(tp,c6374519.thfilter,1,1,nil,tp,e)
	-- 将选中的卡片设置为本效果的处理对象
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息，表示此效果包含将选中的1张卡送回手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 过滤手牌中可以特殊召唤的「惊乐」怪兽
function c6374519.spfilter(c,e,tp)
	return c:IsSetCard(0x15b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：使作为对象的怪兽回到持有者手卡，若成功，则可以从手卡将1只「惊乐」怪兽特殊召唤
function c6374519.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与本效果相关，并将其送回持有者手卡，若成功送回则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 获取自己手牌中满足特殊召唤条件的「惊乐」怪兽
		local g=Duel.GetMatchingGroup(c6374519.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若手牌有可特召的怪兽、怪兽区域有空位，且玩家选择进行特殊召唤
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(6374519,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与回手牌不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
