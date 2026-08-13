--ふわんだりぃずと謎の地図
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只1星「随风旅鸟」怪兽给对方观看，和给人观看的怪兽卡名不同的1张「随风旅鸟」卡从卡组除外。那之后，给人观看的怪兽召唤。
-- ②：对方对怪兽的召唤成功的场合才能发动。自己把1只「随风旅鸟」怪兽召唤。
function c28126717.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从手卡把1只1星「随风旅鸟」怪兽给对方观看，和给人观看的怪兽卡名不同的1张「随风旅鸟」卡从卡组除外。那之后，给人观看的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28126717,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,28126717)
	e1:SetTarget(c28126717.rmtg)
	e1:SetOperation(c28126717.rmop)
	c:RegisterEffect(e1)
	-- ②：对方对怪兽的召唤成功的场合才能发动。自己把1只「随风旅鸟」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28126717,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,28126718)
	e2:SetCondition(c28126717.sumcon)
	e2:SetTarget(c28126717.sumtg)
	e2:SetOperation(c28126717.sumop)
	c:RegisterEffect(e2)
end
-- 手卡怪兽的筛选条件：必须是等级1且属于「随风旅鸟」系列、可以忽略召唤次数进行通常召唤、当前为非公开状态，并且卡组中存在至少1张与它卡名不同的「随风旅鸟」卡可供除外；满足这些条件才能作为①效果的展示怪兽。
function c28126717.rmcfilter(c,tp)
	return c:IsLevel(1) and c:IsSetCard(0x16d) and c:IsSummonable(true,nil) and not c:IsPublic()
		-- 追加检查卡组中是否存在至少1张满足 rmfilter（卡名不同的「随风旅鸟」卡且可被除外）的卡，以确保①效果后续能够执行除外操作。
		and Duel.IsExistingMatchingCard(c28126717.rmfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 卡组中可被除外的卡的条件：属于「随风旅鸟」系列、卡号（代表卡名）与展示怪兽不同，并且当前能够被除外。
function c28126717.rmfilter(c,code)
	return c:IsSetCard(0x16d) and not c:IsCode(code) and c:IsAbleToRemove()
end
-- ①的Target函数：在发动时确认手卡存在至少1只满足 rmcfilter 条件的1星「随风旅鸟」怪兽，同时向系统登记后续处理中将进行‘召唤手卡怪兽’和‘除外卡组卡片’两类操作。
function c28126717.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0 时检查是否存在至少1张满足 rmcfilter 条件的手卡怪兽，作为效果①能否发动的启动判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c28126717.rmcfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 登记操作信息：本次效果处理中将有1张手卡怪兽被通常召唤（位置为手牌，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：本次效果处理中将从卡组把1张卡除外（位置为卡组，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理流程：先从手卡选择并展示1只1星「随风旅鸟」怪兽，再从卡组选择1张不同名的「随风旅鸟」卡除外；若除外成功，则中断处理时点并把展示的怪兽进行通常召唤。
function c28126717.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家从手卡选择1张要展示给对方确认的「随风旅鸟」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张满足 rmcfilter 条件的「随风旅鸟」怪兽，用于给对方观看。
	local g1=Duel.SelectMatchingCard(tp,c28126717.rmcfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		-- 将选中的手卡怪兽展示给对方玩家确认，使其成为公开状态。
		Duel.ConfirmCards(1-tp,g1)
		-- 显示选择提示，要求玩家从卡组选择1张要除外的「随风旅鸟」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从卡组选择1张满足 rmfilter 条件（属于「随风旅鸟」系列、与展示怪兽不同名、可除外）的卡。
		local g2=Duel.SelectMatchingCard(tp,c28126717.rmfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetCode())
		-- 将选中的卡以表侧表示除外；若除外成功（返回值大于0），才继续进行后续的召唤处理。
		if Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)>0 then
			-- 调用 Duel.BreakEffect() 中断当前效果，使后续的召唤与刚才的除外不在同一时点处理，以符合‘那之后’的先后顺序。
			Duel.BreakEffect()
			-- 将展示的怪兽进行通常召唤（ignore_count=true 表示本次召唤不占用本回合的通常召唤次数）。
			Duel.Summon(tp,g1:GetFirst(),true,nil)
		end
	end
end
-- ②的发动条件判断：ep~=tp 表示这次召唤是由对方玩家完成的；只有对方召唤成功时，本效果才能发动。
function c28126717.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 「随风旅鸟」怪兽的可召唤筛选条件：属于「随风旅鸟」系列，并且能够进行通常召唤（忽略本回合的召唤次数限制）。
function c28126717.sumfilter(c)
	return c:IsSetCard(0x16d) and c:IsSummonable(true,nil)
end
-- ②的Target函数：在发动时检查自己场上/手卡是否存在可召唤的「随风旅鸟」怪兽，并登记‘召唤’操作信息。
function c28126717.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0 时检查自己手卡+主要怪兽区是否存在至少1只满足 sumfilter 的「随风旅鸟」怪兽，决定效果②能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28126717.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 登记操作信息：本次连锁将进行1次「召唤」处理（召唤对象在效果处理时确定，因此对象、持有者和位置暂不确定）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②的效果处理流程：选择1只符合条件的「随风旅鸟」怪兽，并对其进行通常召唤（不占用本回合通召次数）。
function c28126717.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要召唤的「随风旅鸟」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从自己手卡+主要怪兽区选择1只满足 sumfilter 条件的「随风旅鸟」怪兽（代码检索范围包含手卡与怪兽区）。
	local g=Duel.SelectMatchingCard(tp,c28126717.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「随风旅鸟」怪兽进行通常召唤（ignore_count=true 表示不占用本回合的通常召唤次数）。
		Duel.Summon(tp,tc,true,nil)
	end
end
