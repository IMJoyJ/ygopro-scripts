--希望郷－オノマトピア－
-- 效果：
-- ①：只要这张卡在场地区域存在，每次自己场上有「希望皇 霍普」怪兽特殊召唤，给这张卡放置1个毅飞冲天指示物。
-- ②：自己场上的怪兽的攻击力·守备力上升这张卡的毅飞冲天指示物数量×200。
-- ③：1回合1次，把这张卡2个毅飞冲天指示物取除才能发动。从卡组把「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽之内任意1只特殊召唤。
function c26493435.initial_effect(c)
	c:EnableCounterPermit(0x30)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，每次自己场上有「希望皇 霍普」怪兽特殊召唤，给这张卡放置1个毅飞冲天指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c26493435.ctcon)
	e2:SetOperation(c26493435.ctop)
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽的攻击力·守备力上升这张卡的毅飞冲天指示物数量×200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(c26493435.val)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：1回合1次，把这张卡2个毅飞冲天指示物取除才能发动。从卡组把「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽之内任意1只特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(26493435,0))  --"放置指示物"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c26493435.spcost)
	e5:SetTarget(c26493435.sptg)
	e5:SetOperation(c26493435.spop)
	c:RegisterEffect(e5)
end
c26493435.mentioned_counter={
	[0x30]=true,
}
-- 过滤函数：判断卡是否为表侧表示、属于「希望皇 霍普」系列且由自己控制的怪兽
function c26493435.ctfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsControler(tp)
end
-- 诱发条件：本次特殊召唤成功的怪兽中存在自己场上的「希望皇 霍普」怪兽
function c26493435.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26493435.ctfilter,1,nil,tp)
end
-- 效果处理：给这张卡放置1个毅飞冲天指示物
function c26493435.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x30,1)
end
-- 计算上升数值：这张卡的毅飞冲天指示物数量×200的攻击力·守备力
function c26493435.val(e,c)
	return e:GetHandler():GetCounter(0x30)*200
end
-- 发动代价：确认可以把这张卡2个毅飞冲天指示物取除，并将其取除作为代价
function c26493435.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x30,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x30,2,REASON_COST)
end
-- 过滤函数：判断卡是否为「刷拉拉」「我我我」「隆隆隆」「怒怒怒」系列且可以特殊召唤的怪兽
function c26493435.filter(c,e,tp)
	return c:IsSetCard(0x8f,0x54,0x59,0x82)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象·发动条件检查：确认自己怪兽区有可用空格，且卡组存在可以特殊召唤的对应系列怪兽
function c26493435.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在至少1只满足条件且可以特殊召唤的对应系列怪兽
		and Duel.IsExistingMatchingCard(c26493435.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：预定从卡组把1只怪兽特殊召唤，供星尘龙等效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：再次确认怪兽区有空格后，让自己从卡组选择1只对应系列怪兽特殊召唤
function c26493435.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己主要怪兽区没有可用空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从卡组选择1只满足条件的「刷拉拉」「我我我」「隆隆隆」「怒怒怒」怪兽
	local g=Duel.SelectMatchingCard(tp,c26493435.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选择的怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
