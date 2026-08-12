--紫炎の道場
-- 效果：
-- ①：每次「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
-- ②：把有武士道指示物放置的这张卡送去墓地才能发动。把持有这张卡放置的武士道指示物数量以下的等级的1只「六武众」效果怪兽或者「紫炎」效果怪兽从卡组特殊召唤。
function c47436247.initial_effect(c)
	c:EnableCounterPermit(0x3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c47436247.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：把有武士道指示物放置的这张卡送去墓地才能发动。把持有这张卡放置的武士道指示物数量以下的等级的1只「六武众」效果怪兽或者「紫炎」效果怪兽从卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(47436247,0))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c47436247.spcost)
	e4:SetTarget(c47436247.sptg)
	e4:SetOperation(c47436247.spop)
	c:RegisterEffect(e4)
end
c47436247.counter_add_list={0x3}
c47436247.mentioned_counter={
	[0x3]=true,
}
-- 过滤函数：判断一张卡是否为表侧表示的「六武众」怪兽（用于检查本次召唤·特殊召唤中是否包含「六武众」怪兽）
function c47436247.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 当召唤·特殊召唤成功的怪兽中存在表侧表示的「六武众」怪兽时，给这张卡放置1个武士道指示物
function c47436247.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c47436247.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x3,1)
	end
end
-- 发动代价：确认这张卡可以作为代价送去墓地，先记录当前放置的武士道指示物数量到Label，再把这张卡送去墓地
function c47436247.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local ct=e:GetHandler():GetCounter(0x3)
	e:SetLabel(ct)
	-- 把这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选等级在武士道指示物数量以下、属于「六武众」或「紫炎」系列的效果怪兽，且可以特殊召唤
function c47436247.filter(c,ct,e,tp)
	return c:IsLevelBelow(ct) and c:IsSetCard(0x103d,0x20)
		and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检测：己方主要怪兽区有空位，且卡组存在可特殊召唤的满足条件的「六武众」或「紫炎」效果怪兽
function c47436247.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在等级在这张卡放置的武士道指示物数量以下的可特殊召唤的「六武众」或「紫炎」效果怪兽
		and Duel.IsExistingMatchingCard(c47436247.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetCounter(0x3),e,tp) end
	-- 设置操作信息：宣告此效果将从卡组特殊召唤1只怪兽，供其他卡的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取出代价时记录的指示物数量，让玩家从卡组选择1只满足条件的怪兽并特殊召唤
function c47436247.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ct=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只等级在指示物数量以下的可特殊召唤的「六武众」或「紫炎」效果怪兽
	local g=Duel.SelectMatchingCard(tp,c47436247.filter,tp,LOCATION_DECK,0,1,1,nil,ct,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
