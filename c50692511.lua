--RR－コール
-- 效果：
-- 「急袭猛禽-呼唤」在1回合只能发动1张，这张卡发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
-- ①：以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从手卡·卡组守备表示特殊召唤。
function c50692511.initial_effect(c)
	-- 对应卡片效果原文：『「急袭猛禽-呼唤」在1回合只能发动1张，这张卡发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。①：以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从手卡·卡组守备表示特殊召唤。』
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50692511+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c50692511.cost)
	e1:SetTarget(c50692511.target)
	e1:SetOperation(c50692511.activate)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，用于跟踪本回合是否进行过非「急袭猛禽」怪兽的特殊召唤；后续cost需保证计数器为0才能发动。
	Duel.AddCustomActivityCounter(50692511,ACTIVITY_SPSUMMON,c50692511.counterfilter)
end
-- 计数器过滤函数：若被特殊召唤的怪兽不是「急袭猛禽」系列（不满足0xba字段），则返回false，使计数器增加，记录这次非「急袭猛禽」特殊召唤。
function c50692511.counterfilter(c)
	return c:IsSetCard(0xba)
end
-- 发动条件与誓约效果：检查本回合尚未特殊召唤过非「急袭猛禽」怪兽，然后给自己附加一个持续到回合结束的『不能特殊召唤非「急袭猛禽」怪兽』的誓约效果。
function c50692511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：确认自定特殊召唤计数为0，即本回合还没有特殊召唤过非「急袭猛禽」怪兽，满足发动前提。
	if chk==0 then return Duel.GetCustomActivityCount(50692511,tp,ACTIVITY_SPSUMMON)==0 end
	-- 对应效果原文中关于誓约限制和①效果处理的语句：『这张卡发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。①：以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从手卡·卡组守备表示特殊召唤。』
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c50692511.splimit)
	-- 将生成的『不能特殊召唤非「急袭猛禽」怪兽』的誓约效果注册给玩家tp，使其在该回合生效。
	Duel.RegisterEffect(e1,tp)
end
-- 誓约效果的判定函数：当尝试特殊召唤的怪兽不是「急袭猛禽」字段（不是0xba）时返回true，表示不允许该特殊召唤。
function c50692511.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xba)
end
-- 对象筛选函数：要求对象是表侧表示的「急袭猛禽」怪兽，并且手卡·卡组中存在同名且可守备表示特殊召唤的怪兽，才可作为效果对象。
function c50692511.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xba)
		-- 检查手卡·卡组中是否存在与对象同卡名（以c:GetCode()传入）且满足filter2的怪兽，数量至少1张。
		and Duel.IsExistingMatchingCard(c50692511.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 候选怪兽筛选函数：卡名与对象当前卡名相同的怪兽，且能被当前效果以表侧守备表示特殊召唤。
function c50692511.filter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标的合法性检查与发动条件检查：连锁处理时校验所选对象是否位于自己场上且与记录卡名相同；发动时确认有怪兽区空格且存在可选的「急袭猛禽」对象。
function c50692511.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsCode(e:GetLabel()) end
	-- 发动条件之一：自己主要怪兽区必须有空位，否则无法进行后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之一：自己场上存在至少1只满足filter1条件、可作为对象的「急袭猛禽」怪兽。
		and Duel.IsExistingTarget(c50692511.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 弹出选择对象的提示信息，提示玩家选择要作为效果对象的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足filter1的「急袭猛禽」怪兽作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c50692511.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，来源区域为手卡·卡组，具体怪兽在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数：在确认空位后，取得对象怪兽，若仍表侧且与效果关联，则从手卡·卡组选择同名怪兽并守备表示特殊召唤。
function c50692511.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否有空位，若已无空位则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果发动时选择的那个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetCode()
		-- 弹出选择要特殊召唤的卡的提示信息，提示玩家从手卡·卡组选择同名怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·卡组中选择1张与对象怪兽同卡名且可以特殊召唤的怪兽。
		local g=Duel.SelectMatchingCard(tp,c50692511.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,code)
		if g:GetCount()>0 then
			-- 将选择到的同名怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
