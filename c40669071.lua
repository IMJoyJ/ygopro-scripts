--エクスコード・トーカー
-- 效果：
-- 电子界族怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功时，指定额外怪兽区域的怪兽数量的没有使用的主要怪兽区域才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
-- ②：这张卡所连接区的怪兽攻击力上升500，不会被效果破坏。
function c40669071.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：这张卡连接召唤成功时，指定额外怪兽区域的怪兽数量的没有使用的主要怪兽区域才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40669071,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,40669071)
	e1:SetCondition(c40669071.lzcon)
	e1:SetTarget(c40669071.lztg)
	e1:SetOperation(c40669071.lzop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽攻击力上升500，不会被效果破坏。
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
-- 效果条件：确认此卡是通过连接召唤方式特殊召唤成功的
function c40669071.lzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：判断目标怪兽是否位于额外怪兽区域（序列大于4）
function c40669071.lzfilter(c)
	return c:GetSequence()>4
end
-- 效果目标：计算己方场上位于额外怪兽区域的怪兽数量，并检查是否有足够的主要怪兽区域可用
function c40669071.lztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上位于额外怪兽区域的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c40669071.lzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return ct>0
		-- 获取己方场上可用的主要怪兽区域数量
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
			-- 获取对方场上可用的主要怪兽区域数量，并与怪兽数量比较
			+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>ct end
	-- 选择指定数量的区域并标记为不可用
	local dis=Duel.SelectDisableField(tp,ct,LOCATION_MZONE,LOCATION_MZONE,0xe000e0)
	e:SetLabel(dis)
	-- 向玩家提示所选择的区域
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 效果处理：将所选区域在该怪兽表侧表示存在期间设为不可用
function c40669071.lzop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	-- 创建一个无效区域的效果，使指定区域在该怪兽存在期间无法使用
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果目标函数：判断目标怪兽是否连接到此卡
function c40669071.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
