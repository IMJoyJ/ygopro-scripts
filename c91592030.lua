--威迫鉱石－サモナイト
-- 效果：
-- ①：以自己墓地3只怪兽为对象才能发动。自己从那3只之中选1只。那之后，对方从以下效果选1个，自己让那个效果适用。
-- ●选的怪兽特殊召唤。
-- ●选的怪兽以外的作为对象的怪兽尽可能特殊召唤。
function c91592030.initial_effect(c)
	-- ①：以自己墓地3只怪兽为对象才能发动。自己从那3只之中选1只。那之后，对方从以下效果选1个，自己让那个效果适用。●选的怪兽特殊召唤。●选的怪兽以外的作为对象的怪兽尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c91592030.target)
	e1:SetOperation(c91592030.activate)
	c:RegisterEffect(e1)
end
-- 过滤出自己墓地可以特殊召唤的怪兽
function c91592030.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检查
function c91592030.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c91592030.filter(chkc,e,tp) end
	-- 检查自己场上是否有至少1个可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少3只可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c91592030.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 提示自己选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地3只可以特殊召唤的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c91592030.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
end
-- 效果处理：自己从3只对象怪兽中选1只，对方选择1个效果适用，并进行相应的特殊召唤处理
function c91592030.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍存在于墓地且仍是合法对象的卡片
	local g=Duel.GetTargetsRelateToChain()
	if #g~=3 then return end
	-- 若自己场上没有可用的怪兽区域，则不进行特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
	-- 提示自己选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 向双方玩家展示自己选择的那1只怪兽
	Duel.HintSelection(sg)
	g:RemoveCard(sg:GetFirst())
	-- 由对方玩家从两个效果中选择一个适用
	local opt=Duel.SelectOption(1-tp,aux.Stringid(91592030,0),aux.Stringid(91592030,1))  --"选的怪兽特殊召唤/选的怪兽以外的作为对象的怪兽尽可能特殊召唤"
	if opt==0 then
		-- 将自己选的那1只怪兽在自己场上特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 获取自己场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		if ft>0 then
			local sg2=g
			if ft<#g then
				-- 提示自己选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sg2=g:Select(tp,ft,ft,nil)
			end
			-- 将选中的其余对象怪兽在自己场上特殊召唤
			Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
