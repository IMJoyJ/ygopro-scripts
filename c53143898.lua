--オルターガイスト・マリオネッター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把1张「幻变骚灵」陷阱卡在自己场上盖放。
-- ②：以自己场上1张「幻变骚灵」卡和自己墓地1只「幻变骚灵」怪兽为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的怪兽特殊召唤。
function c53143898.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1张「幻变骚灵」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53143898,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53143898.settg)
	e1:SetOperation(c53143898.setop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张「幻变骚灵」卡和自己墓地1只「幻变骚灵」怪兽为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53143898,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53143898)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c53143898.sptg)
	e2:SetOperation(c53143898.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「幻变骚灵」陷阱卡：卡名包含0x103字段、类型为陷阱卡、可以盖放
function c53143898.setfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果处理时检查是否满足条件：自己卡组是否存在至少1张满足setfilter条件的陷阱卡
function c53143898.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：自己卡组是否存在至少1张满足setfilter条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c53143898.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理函数，执行将一张「幻变骚灵」陷阱卡从卡组盖放到场上的操作
function c53143898.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组中选择1张满足setfilter条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c53143898.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡盖放到场上
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤函数，用于筛选满足条件的「幻变骚灵」场上卡：卡名包含0x103字段、表侧表示、可以送去墓地
function c53143898.thfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToGrave()
end
-- 过滤函数，用于筛选满足条件的「幻变骚灵」怪兽：卡名包含0x103字段、表侧表示、可以送去墓地且在主要怪兽区（0-4）
function c53143898.thfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToGrave() and c:GetSequence()<5
end
-- 过滤函数，用于筛选满足条件的「幻变骚灵」怪兽：卡名包含0x103字段、可以特殊召唤
function c53143898.spfilter(c,e,tp)
	return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，执行选择对象并设置操作信息的过程
function c53143898.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		local b=false
		if ft>0 then
			-- 检查自己场上是否存在至少1张满足thfilter1条件的卡
			b=Duel.IsExistingTarget(c53143898.thfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		else
			-- 检查自己主要怪兽区是否存在至少1张满足thfilter2条件的卡
			b=Duel.IsExistingTarget(c53143898.thfilter2,tp,LOCATION_MZONE,0,1,nil)
		end
		-- 检查自己墓地是否存在至少1张满足spfilter条件的怪兽
		return b and Duel.IsExistingTarget(c53143898.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g1=nil
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	if ft>0 then
		-- 从自己场上选择1张满足thfilter1条件的卡作为对象
		g1=Duel.SelectTarget(tp,c53143898.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	else
		-- 从自己主要怪兽区选择1张满足thfilter2条件的卡作为对象
		g1=Duel.SelectTarget(tp,c53143898.thfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地中选择1张满足spfilter条件的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c53143898.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的场上卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	-- 设置操作信息：将选中的墓地怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果处理函数，执行将对象卡送去墓地并特殊召唤对象怪兽的操作
function c53143898.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的两个目标卡
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 判断第一个目标卡是否有效且已成功送去墓地
	if tc1:IsRelateToEffect(e) and Duel.SendtoGrave(tc1,REASON_EFFECT)>0
		and tc1:IsLocation(LOCATION_GRAVE) and tc2:IsRelateToEffect(e)
		-- 判断第二个目标怪兽是否有效且未受王家长眠之谷影响
		and aux.NecroValleyFilter()(tc2) then
		-- 将满足条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
