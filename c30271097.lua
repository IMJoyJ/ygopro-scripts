--The Fallen ＆ The Virtuous
-- 效果：
-- 这个卡名在规则上也当作「烙印」卡、「教导」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从额外卡组把有「阿不思的落胤」的卡名记述的1只怪兽送去墓地，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
-- ●自己的场上或墓地有「艾克莉西娅」怪兽存在的场合，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，设置卡名在规则上也当作「烙印」卡、「教导」卡使用，并创建一个发动时点为自由连锁的激活效果，该效果具有取对象属性，发动次数限制为1次
function s.initial_effect(c)
	-- 将卡名「阿不思的落胤」加入该卡的代码列表，用于后续效果判断
	aux.AddCodeList(c,68468459)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于检测额外卡组中是否存在带有「阿不思的落胤」卡名记述的怪兽卡
function s.cfilter(c)
	-- 返回值为真，表示该卡为「阿不思的落胤」怪兽卡且为怪兽类型且可以作为费用送去墓地
	return aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 定义过滤函数，用于检测自己场上或墓地是否存在「艾克莉西娅」怪兽
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1d7) and c:IsType(TYPE_MONSTER)
end
-- 定义过滤函数，用于检测目标怪兽是否可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件和处理流程，包括选择效果选项、处理费用、选择目标、设置连锁操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then
			return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler()
		elseif e:GetLabel()==2 then
			return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp)
		end
		return false
	end
	-- 判断是否满足选项1的发动条件：额外卡组中存在「阿不思的落胤」怪兽卡或未支付费用，且场上存在表侧表示的卡
	local b1=(Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) or not e:IsCostChecked())
		-- 判断是否满足选项1的发动条件：场上存在表侧表示的卡
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	-- 判断是否满足选项2的发动条件：自己场上或墓地存在「艾克莉西娅」怪兽，且自己场上存在空位，且墓地存在可特殊召唤的怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 判断是否满足选项2的发动条件：自己场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足选项2的发动条件：墓地存在可特殊召唤的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动效果的选项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"破坏"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从额外卡组选择1张满足条件的卡送去墓地
			local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 将选中的卡送去墓地作为费用
			Duel.SendtoGrave(g,REASON_COST)
		end
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张表侧表示的卡作为破坏对象
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 设置连锁操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地1只满足条件的怪兽作为特殊召唤对象
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置连锁操作信息为特殊召唤效果
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 处理效果发动后的实际操作，根据选择的选项执行破坏或特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	if e:GetLabel()==1 and tc:IsOnField() then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	-- 判断是否选择选项2且目标卡未受王家长眠之谷影响
	elseif e:GetLabel()==2 and aux.NecroValleyFilter()(tc) then
		-- 将目标卡特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
