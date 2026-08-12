--Live☆Twin リィラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，若自己场上没有其他怪兽存在则能发动。从手卡·卡组把1只「姬丝基勒」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能攻击宣言。
function c73810864.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，若自己场上没有其他怪兽存在则能发动。从手卡·卡组把1只「姬丝基勒」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73810864,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,73810864)
	e1:SetCondition(c73810864.spcon)
	e1:SetTarget(c73810864.sptg)
	e1:SetOperation(c73810864.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_ATTACK_COST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCost(c73810864.atcost)
	e3:SetOperation(c73810864.atop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能攻击宣言。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_FLAG_EFFECT+73810864)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
end
-- 定义①效果的发动条件函数
function c73810864.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为1（即只有刚召唤的这张卡本身，没有其他怪兽）
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 过滤函数：筛选手卡·卡组中可以特殊召唤的「姬丝基勒」怪兽
function c73810864.spfilter(c,e,tp)
	return c:IsSetCard(0x152) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果的发动准备函数（检查怪兽区域空位及手卡·卡组中是否存在可特召的「姬丝基勒」怪兽）
function c73810864.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只可以特殊召唤的「姬丝基勒」怪兽
		and Duel.IsExistingMatchingCard(c73810864.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（用于连锁处理时的检测）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义①效果的效果处理函数（从手卡·卡组特殊召唤1只「姬丝基勒」怪兽）
function c73810864.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只「姬丝基勒」怪兽
	local g=Duel.SelectMatchingCard(tp,c73810864.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选定的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义攻击宣言代价检查函数
function c73810864.atcost(e,c,tp)
	-- 获取对方玩家身上注册的本卡效果标记数量（即场上存在的「直播☆双子 璃拉」数量）
	local ct=Duel.GetFlagEffect(tp,73810864)
	-- 检查对方玩家是否能够支付 500 * 璃拉数量 的基本分
	return Duel.CheckLPCost(tp,ct*500)
end
-- 定义攻击宣言代价支付函数
function c73810864.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示正在适用「直播☆双子 璃拉」的效果
	Duel.Hint(HINT_CARD,0,73810864)
	-- 让对方玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
