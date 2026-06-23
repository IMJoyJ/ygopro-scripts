--X・HERO ワンダー・ドライバー
-- 效果：
-- 「英雄」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：作为这张卡所连接区的自己场上有「英雄」怪兽召唤·特殊召唤的场合，以自己墓地的「融合」魔法卡、「变化」速攻魔法卡的其中1张为对象发动。那张卡在自己场上盖放。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从手卡把1只「英雄」怪兽特殊召唤。
function c1948619.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只属于英雄卡组的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2,2)
	-- ①：作为这张卡所连接区的自己场上有「英雄」怪兽召唤·特殊召唤的场合，以自己墓地的「融合」魔法卡、「变化」速攻魔法卡的其中1张为对象发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1948619,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,1948619)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1948619.setcon)
	e1:SetTarget(c1948619.settg)
	e1:SetOperation(c1948619.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从手卡把1只「英雄」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c1948619.spcon)
	e3:SetTarget(c1948619.sptg)
	e3:SetOperation(c1948619.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断召唤或特殊召唤的怪兽是否在连接区中
function c1948619.setcfilter(c,tp,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0x8) and c:IsFaceup() and c:IsControler(tp) and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0x8) and c:IsPreviousPosition(POS_FACEUP)
			and c:IsPreviousControler(tp) and bit.extract(ec:GetLinkedZone(tp),c:GetPreviousSequence())~=0
	end
end
-- 判断是否有满足条件的怪兽在连接区中
function c1948619.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1948619.setcfilter,1,nil,tp,e:GetHandler())
end
-- 过滤函数，用于筛选墓地中的融合魔法卡或变化速攻魔法卡
function c1948619.setfilter(c)
	return ((c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)) or (c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0xa5))) and c:IsSSetable()
end
-- 设置效果的目标为满足条件的墓地魔法卡
function c1948619.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1948619.setfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的墓地魔法卡作为目标
	local g=Duel.SelectTarget(tp,c1948619.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，标记将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行效果操作，将目标卡在自己场上盖放
function c1948619.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 判断此卡是否因战斗或对方效果破坏而进入墓地
function c1948619.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 过滤函数，用于筛选手卡中的英雄怪兽
function c1948619.spfilter(c,e,tp)
	return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标为满足条件的手卡英雄怪兽
function c1948619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的英雄怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的英雄怪兽
		and Duel.IsExistingMatchingCard(c1948619.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果操作信息，标记将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果操作，从手卡特殊召唤满足条件的英雄怪兽
function c1948619.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手卡英雄怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c1948619.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将目标怪兽从手卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
