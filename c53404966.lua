--焔聖騎士－リッチャルデット
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡·墓地的这张卡除外才能发动。从手卡把1只4星以下的战士族·炎属性怪兽当作调整使用特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以除「焰圣骑士-里恰尔代托」外的自己墓地1只4星以下的战士族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册①效果（手卡/墓地除外后从手卡特召并当作调整）和②效果（召唤/特殊召唤时从墓地特召并附加自肃）；②用Clone同时对应召唤成功与特殊召唤成功两个时点；①②通过相同CountLimit实现“这个卡名的①②的效果1回合只能有1次使用其中任意1个”。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把手卡·墓地的这张卡除外才能发动。从手卡把1只4星以下的战士族·炎属性怪兽当作调整使用特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	-- 设置①效果的发动COST：把手卡·墓地的这张卡除外（发动时支付）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合，以除「焰圣骑士-里恰尔代托」外的自己墓地1只4星以下的战士族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义特召对象的筛选条件：炎属性·战士族·4星以下，且能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查发动条件：自己主要怪兽区有空位，且手卡存在1只满足筛选条件的怪兽（排除此卡自身）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在1只满足s.spfilter条件的怪兽（ex排除效果发动者自身）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置效果处理信息：本次操作包含特殊召唤分类，预期从手卡特殊召唤1只怪兽，处理对象为不确定（效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：从手卡选1只符合条件的怪兽特殊召唤，并赋予其调整属性；使用SpecialSummonStep/Complete完成特殊召唤处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区是否有空位，若无则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足s.spfilter的怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		-- 将选择的怪兽以表侧攻击表示特殊召唤（分步处理），若成功则继续赋予其调整属性。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			-- 当作调整使用
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的分步处理，结束本次特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
-- 定义②特召对象的筛选条件：满足①效果的条件，且卡名不是「焰圣骑士-里恰尔代托」。
function s.spfilter2(c,e,tp)
	return s.spfilter(c,e,tp) and not c:IsCode(id)
end
-- ②效果发动判定：自己主要怪兽区有空位，且墓地存在满足条件的对象；对象合法性检查时确认其在墓地、属于自己且符合筛选。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只满足s.spfilter2条件的怪兽，且该怪兽能被选择为对象（取对象）。
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足s.spfilter2的怪兽作为效果对象（同时设定为连锁对象）。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：确定将特殊召唤所选择的墓地怪兽（对象已在发动时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- ②效果处理：若仍有空位且对象有效，则特殊召唤对象怪兽；随后给自己附加直到回合结束的召唤限制：只能特殊召唤战士族怪兽。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上仍有可用主要怪兽区空格，则处理特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 取得发动时选择的对象怪兽（通常为1张）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象怪兽以表侧攻击表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，影响自己，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果判定函数：若特殊召唤的怪兽不是战士族，则禁止特殊召唤（返回true表示不能特召）。
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
