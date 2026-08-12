--次元融合殺
-- 效果：
-- ①：从自己的手卡·场上·墓地把「幻魔」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的战斗发生的对自己的战斗伤害变成0。自己场上有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中任意种存在的场合，对方不能对应这张卡的发动把效果发动。
function c89190953.initial_effect(c)
	-- 在卡片中注册其记载的「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」的卡片密码
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- ①：从自己的手卡·场上·墓地把「幻魔」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的战斗发生的对自己的战斗伤害变成0。自己场上有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中任意种存在的场合，对方不能对应这张卡的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89190953.target)
	e1:SetOperation(c89190953.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于筛选自己手卡、场上、墓地中可以被除外且不受当前效果影响的卡片作为融合素材
function c89190953.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：用于筛选额外卡组中属于「幻魔」系列、可以无视召唤条件特殊召唤，且能用当前素材进行融合召唤的融合怪兽
function c89190953.filter2(c,e,tp,m,chkf)
	return c:IsSetCard(0x144) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf,true)
end
-- 过滤条件：用于筛选自己场上表侧表示存在的「神炎皇 乌利亚」、「降雷皇 哈蒙」或「幻魔皇 拉比艾尔」
function c89190953.chfilter(c)
	return c:IsFaceup() and c:IsCode(6007213,32491822,69890967)
end
-- 效果发动时的目标选择与连锁限制处理
function c89190953.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 获取自己手卡、场上、墓地中可以作为融合素材除外的卡片组
		local mg=Duel.GetMatchingGroup(c89190953.filter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组是否存在至少1只可以使用上述素材进行融合召唤的「幻魔」融合怪兽
		return Duel.IsExistingMatchingCard(c89190953.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	-- 检查是否是魔法卡的发动，且自己场上是否存在「神炎皇 乌利亚」、「降雷皇 哈蒙」或「幻魔皇 拉比艾尔」中的任意一种
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(c89190953.chfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 限制连锁，使得对方不能对应这张卡的发动把效果发动
		Duel.SetChainLimit(c89190953.chainlm)
	end
	-- 设置操作信息：此效果包含将手卡、场上、墓地的卡除外的处理
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	-- 设置操作信息：此效果包含从额外卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动后的具体处理逻辑（除外素材、特殊召唤融合怪兽并赋予战斗伤害为0的效果）
function c89190953.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 获取自己手卡、场上、墓地中可以作为融合素材除外的卡片组（受王家之谷影响）
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c89190953.filter1),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中满足召唤条件的「幻魔」融合怪兽
	local sg=Duel.GetMatchingGroup(c89190953.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 让玩家选择用于融合召唤目标怪兽的融合素材
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		-- 将选中的融合素材怪兽表侧表示除外
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT)
		-- 中断当前效果，使后续的特殊召唤处理不与除外同时进行（避免影响时点）
		Duel.BreakEffect()
		-- 尝试将目标融合怪兽无视召唤条件以表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的战斗发生的对自己的战斗伤害变成0。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c89190953.damcon)
			e1:SetValue(1)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
			e2:SetCondition(c89190953.damcon2)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 战斗伤害变成0效果的适用条件（怪兽在自己场上时，自己不会受到战斗伤害）
function c89190953.damcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 战斗伤害变成0效果的适用条件（怪兽在对方场上时，该怪兽不会对玩家造成战斗伤害）
function c89190953.damcon2(e)
	return 1-e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 连锁限制函数：仅允许发动该效果的玩家进行连锁（即对方不能对应发动效果）
function c89190953.chainlm(e,ep,tp)
	return tp==ep
end
