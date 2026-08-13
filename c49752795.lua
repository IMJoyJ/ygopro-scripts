--双天の再来
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本等级是4星以下的「双天」怪兽特殊召唤的场合，可以再在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。
function c49752795.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本等级是4星以下的「双天」怪兽特殊召唤的场合，可以再在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,49752795+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c49752795.target)
	e1:SetOperation(c49752795.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否拥有「双天」字段且能被效果特殊召唤（满足苏生限制与召唤手续）。
function c49752795.filter(c,e,tp)
	return c:IsSetCard(0x14f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对象/发动合法性判定：若检查对象则要求对象在自己墓地且满足filter；若为发动时检查，则需自己主要怪兽区有空位且墓地存在符合条件的「双天」怪兽。
function c49752795.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c49752795.filter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区必须存在至少1个可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：自己墓地存在至少1只满足filter且可作为效果对象的「双天」怪兽。
		and Duel.IsExistingTarget(c49752795.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足filter的「双天」怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c49752795.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果处理包含特殊召唤，目标为该对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	local tc=g:GetFirst()
	if tc:GetOriginalLevel()<=4 then
		-- 若对象原本等级为4星以下，额外登记本次效果可能包含衍生物的特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	end
end
-- 效果处理：将对象怪兽特殊召唤；若其原本等级为4星以下且满足条件，则追加特殊召唤「双天魂衍生物」。
function c49752795.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中作为对象的那张卡（若仍与效果关联）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤，并检查是否特殊召唤成功、原本等级是否≤4以及主要怪兽区是否有空位。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:GetOriginalLevel()<=4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够按指定参数特殊召唤「双天魂衍生物」（战士族·光·2星·攻/守0，字段「双天」），并询问玩家是否要特殊召唤衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) and Duel.SelectYesNo(tp,aux.Stringid(49752795,0)) then  --"是否要特殊召唤衍生物？"
			-- 中断当前效果处理，使后续衍生物的特殊召唤与之前的特殊召唤不同时处理。
			Duel.BreakEffect()
			-- 生成1只「双天魂衍生物」衍生物（token）。
			local token=Duel.CreateToken(tp,49752796)
			-- 将「双天魂衍生物」衍生物表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
