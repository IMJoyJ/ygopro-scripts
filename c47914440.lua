--レーン・リストリクション
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- ①：作为这张卡的发动时的效果处理，可以把自己的除外状态的1只怪兽在自己的右端的主要怪兽区域特殊召唤。
-- ②：对方在自身的主要怪兽区域把怪兽召唤·特殊召唤的场合，必须从可以使用的最左边的区域起有顺序使用。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以把自己的除外状态的1只怪兽在自己的右端的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方在自身的主要怪兽区域把怪兽召唤·特殊召唤的场合，必须从可以使用的最左边的区域起有顺序使用。（额外卡组的灵摆/连接怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_USE_MZONE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_EXTRA)
	e2:SetTarget(s.frctg1)
	e2:SetValue(s.frcval2)
	c:RegisterEffect(e2)
	-- ②：对方在自身的主要怪兽区域把怪兽召唤·特殊召唤的场合，必须从可以使用的最左边的区域起有顺序使用。（其他怪兽）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_USE_MZONE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,0xff)
	e3:SetTarget(s.frctg2)
	e3:SetValue(s.frcval2)
	c:RegisterEffect(e3)
end
-- 过滤除外状态的且能在自己右端主要怪兽区域特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,0x10)
end
-- 卡片发动时的效果处理：特召除外状态的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断自己怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测除外状态是否存在可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 玩家选择是否在右端的主要怪兽区域特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只除外状态的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽在右端的主要怪兽区域特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x10)
		end
	end
end
-- 过滤受限制的额外卡组怪兽（表侧表示灵摆怪兽或连接怪兽）
function s.frctg1(e,c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_LINK)
end
-- 过滤其他不受额外卡组限制的怪兽
function s.frctg2(e,c)
	return not (c:IsLocation(LOCATION_EXTRA) and (c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_LINK)))
end
-- 过滤表侧表示的连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 对于连接状态怪兽，计算必须使用的最左边的区域
function s.frcval1(e,c,fp,rp,r)
	-- 获取对方被连接区域的位掩码
	local lzone=Duel.GetLinkedZone(1-e:GetHandlerPlayer())
	for seq=0,4 do
		if (lzone&(1<<seq))~=0
			-- 且对应的主要怪兽区域没有卡存在
			and not Duel.GetFieldCard(1-e:GetHandlerPlayer(),LOCATION_MZONE,seq)
			-- 且该位置是可以使用的空格
			and Duel.GetLocationCount(1-e:GetHandlerPlayer(),LOCATION_MZONE,1-e:GetHandlerPlayer(),LOCATION_REASON_TOFIELD,1<<seq)>0 then
			return ((1<<seq)*0x10000) | 0x600060
		end
	end
	return 0x600060
end
-- 计算必须使用的最左边的区域
function s.frcval2(e,c,fp,rp,r)
	local zone=0x0
	for seq=0,4 do
		-- 若对应的主要怪兽区域没有卡存在
		if not Duel.GetFieldCard(1-e:GetHandlerPlayer(),LOCATION_MZONE,seq)
			-- 且该位置是可以使用的空格
			and Duel.GetLocationCount(1-e:GetHandlerPlayer(),LOCATION_MZONE,1-e:GetHandlerPlayer(),LOCATION_REASON_TOFIELD,1<<seq)>0 then
			return ((1<<seq)*0x10000) | 0x600060
		end
	end
	return 0x600060
end
