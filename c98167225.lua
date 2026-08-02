--創神のヴァルモニカ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有响鸣指示物6个以上存在，自己场上的「异响鸣」连接怪兽的攻击力上升1200。
-- ②：对方把怪兽特殊召唤的场合才能发动。进行1只「异响鸣」连接怪兽的连接召唤。
-- ③：这张卡从手卡·场上送去墓地的场合才能发动。给可以放置响鸣指示物的自己的灵摆区域1张卡放置响鸣指示物到变成3个。
local s,id,o=GetID()
-- 注册卡片的发动以及攻击力上升、连接召唤、放置指示物的效果
function s.initial_effect(c)
	-- （卡片的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制不能在伤害步骤发动
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有响鸣指示物6个以上存在，自己场上的「异响鸣」连接怪兽的攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
	-- ②：对方把怪兽特殊召唤的场合才能发动。进行1只「异响鸣」连接怪兽的连接召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"连接召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡从手卡·场上送去墓地的场合才能发动。给可以放置响鸣指示物的自己的灵摆区域1张卡放置响鸣指示物到变成3个。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"放置指示物"
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.coucon)
	e4:SetTarget(s.coutg)
	e4:SetOperation(s.couop)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 判断卡片是否放置有响鸣指示物
function s.cfilter(c)
	return c:GetCounter(0x6a)>0
end
-- 获取卡片上放置的响鸣指示物的数量
function s.iee(c)
	return c:GetCounter(0x6a)
end
-- 判断自己场上所有卡的响鸣指示物总数是否大于5个
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有放置有响鸣指示物的卡
	local sg=Duel.GetMatchingGroup(s.cfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,nil)
	local ct=sg:GetSum(s.iee)
	return ct>5
end
-- 判断卡片是否为「异响鸣」连接怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 判断特殊召唤的怪兽中是否存在由对方特殊召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 判断额外卡组的卡是否为可以连接召唤的「异响鸣」连接怪兽
function s.spfilter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0x1a3)
end
-- 判断额外卡组是否存在可以连接召唤的「异响鸣」连接怪兽并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只可以连接召唤的「异响鸣」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息，预计特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理，让玩家选择1只「异响鸣」连接怪兽并进行连接召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只可以连接召唤的「异响鸣」连接怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽进行连接召唤
		Duel.LinkSummon(tp,tc,nil)
	end
end
-- 判断这张卡是否从手卡或场上送去墓地
function s.coucon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 判断是否为表侧表示、可以放置响鸣指示物且指示物不满3个的卡
function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x6a,1) and c:GetCounter(0x6a)<3
end
-- 判断灵摆区域是否存在符合条件的卡并设置放置指示物的操作信息
function s.coutg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 获取自己的灵摆区域所有符合条件的卡
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_PZONE,0,nil)
	-- 设置操作信息，预计给符合条件的卡放置响鸣指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0x6a)
end
-- 效果处理，让玩家选择灵摆区域1张卡并为其补充响鸣指示物至3个
function s.couop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1张符合条件的灵摆区域的卡
	local tc=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
	if tc then
		local ct=3-tc:GetCounter(0x6a)
		if ct>0 then
			tc:AddCounter(0x6a,ct)
			if tc:GetCounter(0x6a)==3 then
				-- 触发放置指示物满3个时的自定义事件，用于处理异响鸣相关效果
				Duel.RaiseEvent(tc,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
			end
		end
	end
end
