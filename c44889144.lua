--リブロマンサー・インターフェア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，以自己场上1只「书灵师」仪式怪兽为对象才能发动。那只怪兽回到持有者手卡，那个发动的效果无效。那之后，可以从自己的手卡·墓地选1只「书灵师」怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：创建并注册这张卡的①效果（对方发动效果时以自己场上的书灵师仪式怪兽为对象，使其回手并无效对方效果，之后可选特殊召唤），同时用CountLimit设置该卡名1回合只能发动1张。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方把魔法·陷阱·怪兽的效果发动时，以自己场上1只「书灵师」仪式怪兽为对象才能发动。那只怪兽回到持有者手卡，那个发动的效果无效。那之后，可以从自己的手卡·墓地选1只「书灵师」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.f2hcon)
	e1:SetTarget(s.f2htg)
	e1:SetOperation(s.f2hop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：确认是对方（ep≠tp）发动魔法·陷阱·怪兽的效果，且该效果处于可被无效的状态（Duel.IsChainDisablable）。
function s.f2hcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件具体为：当前连锁的效果的发动者是对方玩家，且该效果允许被无效。
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 定义对象筛选函数：选取自己场上表侧表示、属于「书灵师」系列、是仪式怪兽且能够返回手卡的怪兽。
function s.f2hfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果发动时的目标选择函数：在满足条件时选择对象，并设置效果处理信息为回手+无效对方效果。
function s.f2htg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.f2hfilter(chkc) end
	-- 发动时判定：自己场上是否存在至少1只满足筛选条件的「书灵师」仪式怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.f2hfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示，让玩家选择要返回手牌的对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从自己场上选择1只符合条件的「书灵师」仪式怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.f2hfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：该效果包含把对象卡返回手牌的处理，对象为g，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	-- 设置操作信息：该效果包含无效对方发动的效果（eg）的处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义特殊召唤筛选函数：选取属于「书灵师」系列且可以被当前效果正常特殊召唤（检查召唤条件和苏生限制）的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理函数：将对象怪兽返回手牌，成功后无效对方发动的那次效果；若自己场上还有空位且手卡/墓地存在可特召的「书灵师」怪兽，则询问玩家是否再进行特殊召唤。
function s.f2hop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽（第一只目标）。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽仍与该效果关联，并把它返回持有者手牌；只有返回成功时才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		-- 确认目标已回到手牌后，使对方发动的那个效果无效。
		and tc:IsLocation(LOCATION_HAND) and Duel.NegateEffect(ev)
		-- 检查自己场上是否有可用的怪兽区域，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只可特殊召唤、且不受王家长眠之谷影响的「书灵师」怪兽。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 让玩家选择是否进行后续的特殊召唤（是/否）。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选1只「书灵师」怪兽特殊召唤？"
		-- 显示选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从自己的手卡或墓地选择1只符合条件的「书灵师」怪兽（排除受王家长眠之谷影响的卡）。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #sg>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
