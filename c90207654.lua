--極星天グルヴェイグ
-- 效果：
-- 5星以下的「极星」怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。选自己的手卡·场上最多3张卡除外，把那个数量的「极星」怪兽从卡组守备表示特殊召唤。这个效果发动过的回合，自己不能通常召唤，不是「极神」怪兽不能特殊召唤。
-- ②：只要这张卡所连接区有「极神」怪兽存在，对方不能把那只怪兽作为效果的对象，不能选择这张卡作为攻击对象。
function c90207654.initial_effect(c)
	c:EnableReviveLimit()
	-- 为自身添加连接召唤手续，需要1只5星以下的「极星」怪兽作为素材。
	aux.AddLinkProcedure(c,c90207654.matfilter,1,1)
	-- ①：这张卡连接召唤成功的场合才能发动。选自己的手卡·场上最多3张卡除外，把那个数量的「极星」怪兽从卡组守备表示特殊召唤。这个效果发动过的回合，自己不能通常召唤，不是「极神」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90207654,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,90207654)
	e1:SetCondition(c90207654.spcon)
	e1:SetTarget(c90207654.sptg)
	e1:SetOperation(c90207654.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡所连接区有「极神」怪兽存在，对方不能把那只怪兽作为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c90207654.tgcon)
	e2:SetTarget(c90207654.tgtg)
	-- 设置不能成为对方的效果对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 不能选择这张卡作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c90207654.tgcon)
	-- 设置不能成为攻击对象。
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
end
-- 过滤连接素材：5星以下的「极星」怪兽。
function c90207654.matfilter(c)
	return c:IsLinkSetCard(0x42) and c:IsLevelBelow(5)
end
-- 效果①的发动条件：此卡是连接召唤成功的。
function c90207654.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤除外后能腾出怪兽区域的卡片。
function c90207654.rmfilter(c,tp)
	-- 检查将该卡除外后，自己场上是否有可用的怪兽区域。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 过滤卡组中可以守备表示特殊召唤的「极星」怪兽。
function c90207654.spfilter(c,e,tp)
	return c:IsSetCard(0x42) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与合法性检测。
function c90207654.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·场上所有可以除外的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 检查发动时自己手卡或场上是否存在至少1张除外后能留出怪兽格子的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c90207654.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp)
		-- 并且检查卡组中是否存在至少1只可以特殊召唤的「极星」怪兽。
		and Duel.IsExistingMatchingCard(c90207654.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：除外卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁处理的操作信息：从卡组特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义动态检测除外卡片数量与特殊召唤所需怪兽区域数量是否匹配的辅助函数。
function c90207654.gcheck(tp)
	return	function(sg)
				-- 检查除外选定的卡片组后，腾出的怪兽区域数量是否大于或等于要特殊召唤的怪兽数量。
				return Duel.GetMZoneCount(tp,sg)>=#sg
			end
end
-- 效果①的实际效果处理。
function c90207654.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己手卡·场上可以除外的卡片组。
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 计算卡组中满足特殊召唤条件的「极星」怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c90207654.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if ct>3 then ct=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 注册额外的组选择检查函数，确保除外后有足够的怪兽格子进行特殊召唤。
	aux.GCheckAdditional=c90207654.gcheck(tp)
	-- 让玩家选择1到ct张（最多3张）要除外的卡。
	local sg=rg:SelectSubGroup(tp,aux.TRUE,false,1,ct)
	-- 重置组选择检查函数。
	aux.GCheckAdditional=nil
	-- 将选中的卡表侧表示除外，并检查是否成功除外了至少1张卡。
	if sg and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取实际被除外的卡片数量。
		local ct=#(Duel.GetOperatedGroup())
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择与除外数量相同的「极星」怪兽。
		local tg=Duel.SelectMatchingCard(tp,c90207654.spfilter,tp,LOCATION_DECK,0,ct,ct,nil,e,tp)
		-- 将选中的怪兽在自己场上表侧守备表示特殊召唤。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 不是「极神」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c90207654.splimit)
	-- 注册不能特殊召唤「极神」以外怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
	-- 这个效果发动过的回合，自己不能通常召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 注册本回合不能通常召唤的限制效果。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	-- 注册本回合不能盖放怪兽的限制效果。
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制：过滤非「极神」怪兽。
function c90207654.splimit(e,c)
	return not c:IsSetCard(0x4b)
end
-- 过滤表侧表示的「极神」怪兽。
function c90207654.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 保护效果的启用条件：此卡所连接区存在表侧表示的「极神」怪兽。
function c90207654.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(c90207654.tgfilter,1,nil)
end
-- 效果对象保护的适用目标：此卡所连接区的「极神」怪兽。
function c90207654.tgtg(e,c)
	return c90207654.tgfilter(c) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
