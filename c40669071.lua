--エクスコード・トーカー
-- 效果：
-- 电子界族怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功时，指定额外怪兽区域的怪兽数量的没有使用的主要怪兽区域才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
-- ②：这张卡所连接区的怪兽攻击力上升500，不会被效果破坏。
function c40669071.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，要求使用2只以上电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤成功时，指定额外怪兽区域的怪兽数量的没有使用的主要怪兽区域才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40669071,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,40669071)
	e1:SetCondition(c40669071.lzcon)
	e1:SetTarget(c40669071.lztg)
	e1:SetOperation(c40669071.lzop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c40669071.tgtg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡以连接召唤方式特殊召唤成功。
function c40669071.lzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选位于额外怪兽区域的怪兽（序号大于4），用于统计额外怪兽区域中的怪兽数量。
function c40669071.lzfilter(c)
	return c:GetSequence()>4
end
-- 效果①的发动条件与目标选择：计算额外怪兽区域的怪兽数量ct；若ct>0且双方空余主要怪兽区域数量之和大于ct，则可发动；发动时选择ct个未使用的主要怪兽区域并存入效果标签。
function c40669071.lztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计双方场上额外怪兽区域中的怪兽总数（作为需要选择禁用的主要怪兽区域数量）。
	local ct=Duel.GetMatchingGroupCount(c40669071.lzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return ct>0
		-- 获取自己场上可用的主要怪兽区域数量。
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
			-- 再加上对方场上可用的主要怪兽区域数量，并与额外怪兽区域怪兽数ct比较：只有总数大于ct时才满足发动条件。
			+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>ct end
	-- 让玩家tp在双方场上可选怪兽区域中，选择ct个未使用的区域（0xe000e0限定可选的区域位标记），返回选中区域的位标记。
	local dis=Duel.SelectDisableField(tp,ct,LOCATION_MZONE,LOCATION_MZONE,0xe000e0)
	e:SetLabel(dis)
	-- 将选中的区域以高亮方式提示给玩家，展示将要无效化的区域。
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 效果①处理：取出发动时选定的区域位标记，若发动玩家为1号玩家则交换高低16位以统一坐标；随后给这张卡注册一个永续效果，使这些区域在卡片表侧表示期间不能使用，且该无效化效果不会被无效，并在卡片离场/回手/回卡组等标准时机重置。
function c40669071.lzop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	-- 指定的区域在这只怪兽表侧表示存在期间不能使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：判断卡片c是否为这张卡所连接区的怪兽（即c是否位于这张卡的链接区内），用于②的攻击力上升和不会被效果破坏的适用对象筛选。
function c40669071.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
