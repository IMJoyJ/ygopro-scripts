--BK プロモーター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。
-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从卡组把「燃烧拳击手 推广人」以外的最多2只「燃烧拳击手」怪兽特殊召唤（同名卡最多1张）。
-- ③：把墓地的这张卡除外才能发动。自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
function c83315222.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83315222,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,83315222)
	e1:SetCondition(c83315222.spcon)
	e1:SetCost(c83315222.cost)
	e1:SetTarget(c83315222.sptg1)
	e1:SetOperation(c83315222.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。②：把这张卡解放才能发动。从卡组把「燃烧拳击手 推广人」以外的最多2只「燃烧拳击手」怪兽特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83315222,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,83315223)
	e2:SetCost(c83315222.spcost)
	e2:SetTarget(c83315222.sptg2)
	e2:SetOperation(c83315222.spop2)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。③：把墓地的这张卡除外才能发动。自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83315222,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,83315224)
	e3:SetCost(c83315222.lvcost)
	e3:SetTarget(c83315222.lvtg)
	e3:SetOperation(c83315222.lvop)
	c:RegisterEffect(e3)
	-- 设定自定义特殊召唤计数器，用以监控本回合玩家是否特殊召唤过「燃烧拳击手」以外的怪兽
	Duel.AddCustomActivityCounter(83315222,ACTIVITY_SPSUMMON,c83315222.counterfilter)
end
-- 特殊召唤计数器的过滤条件：判断特殊召唤的怪兽是否为表侧表示的「燃烧拳击手」怪兽
function c83315222.counterfilter(c)
	return c:IsSetCard(0x1084) and c:IsFaceup()
end
-- 本回合不能特殊召唤「燃烧拳击手」怪兽以外怪兽的誓约效果的检测与注册
function c83315222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家在本回合内是否未进行过「燃烧拳击手」怪兽以外的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(83315222,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。②：把这张卡解放才能发动。从卡组把「燃烧拳击手 推广人」以外的最多2只「燃烧拳击手」怪兽特殊召唤（同名卡最多1张）。③：把墓地的这张卡除外才能发动。自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c83315222.splimit)
	e1:SetLabelObject(e)
	-- 在全局环境中注册该不能特殊召唤「燃烧拳击手」以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤条件：不能特殊召唤「燃烧拳击手」以外的怪兽
function c83315222.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1084)
end
-- 判断对方场上是否有怪兽存在以满足效果①的发动条件
function c83315222.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果①的发动检测：检测自己场上的怪兽区域是否有空位且自身能否特殊召唤
function c83315222.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息：特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：自身从手卡以表侧表示特殊召唤
function c83315222.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动代价检测：检测是否能将自身解放且满足限制条件
function c83315222.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		and c83315222.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 解放自身作为效果发动的代价
	Duel.Release(c,REASON_COST+REASON_RELEASE)
	c83315222.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤条件：卡组中除「燃烧拳击手 推广人」以外且可特殊召唤的「燃烧拳击手」怪兽
function c83315222.spfilter(c,e,tp)
	return c:IsSetCard(0x1084) and not c:IsCode(83315222) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检测自身解放后是否有空余的怪兽区域且卡组存在可特殊召唤的目标怪兽
function c83315222.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自身解放离开场上后怪兽区域是否有可用的位置
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检测卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c83315222.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：根据空位与特殊限制，从卡组特殊召唤最多2只卡名不同的「燃烧拳击手」怪兽
function c83315222.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 计算本次特殊召唤的最大数量（最大为2与可用格子数的较小值）
	local ft=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有满足过滤条件的「燃烧拳击手」怪兽
	local g=Duel.GetMatchingGroup(c83315222.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1到ft只卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if sg then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动代价检测：检测墓地的自身是否能除外且满足特召限制条件
function c83315222.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and c83315222.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 将墓地的自身除外作为效果发动的代价
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	c83315222.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤条件：自己场上表侧表示且等级在1以上的「燃烧拳击手」怪兽
function c83315222.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:IsLevelAbove(1)
end
-- 效果③的发动准备：检测场上是否存在等级在1以上的表侧表示「燃烧拳击手」怪兽
function c83315222.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在符合过滤条件的表侧表示「燃烧拳击手」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83315222.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果③的效果处理：使自己场上的「燃烧拳击手」怪兽等级全部上升1星或全部下降1星
function c83315222.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有符合等级调整条件的怪兽
	local g=Duel.GetMatchingGroup(c83315222.lvfilter,tp,LOCATION_MZONE,0,nil)
	local sel=0
	local lv=1
	if not g:IsExists(Card.IsLevelAbove,1,nil,2) then
		-- 若场上没有等级2以上的怪兽，则选项仅有等级上升
		sel=Duel.SelectOption(tp,aux.Stringid(83315222,3))  --"等级上升"
	else
		-- 若场上存在等级2以上的怪兽，让玩家在等级上升和等级下降之间进行选择
		sel=Duel.SelectOption(tp,aux.Stringid(83315222,3),aux.Stringid(83315222,4))  --"等级上升/等级下降"
	end
	if sel==1 then
		lv=-1
	end
	-- 遍历所有需要调整等级的怪兽
	for tc in aux.Next(g) do
		-- 自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
