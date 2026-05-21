--アセット・マウンティス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方场上有6星以下的怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己手卡比对方多的场合才能发动。场上的全部怪兽的表示形式变更。场上的其他的昆虫族怪兽的属性·等级变成和这张卡相同。这个回合，自己不是昆虫族怪兽不能特殊召唤。
-- ③：这张卡被破坏的场合才能发动。从卡组把1只8星以上的昆虫族怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册①②③效果
function s.initial_effect(c)
	-- ①：对方场上有6星以下的怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己手卡比对方多的场合才能发动。场上的全部怪兽的表示形式变更。场上的其他的昆虫族怪兽的属性·等级变成和这张卡相同。这个回合，自己不是昆虫族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。从卡组把1只8星以上的昆虫族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且等级6以下的怪兽
function s.spfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6)
end
-- ①效果的发动条件：对方场上存在满足过滤条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在表侧表示且等级6以下的怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- ①效果的发动准备：检查怪兽区域空位以及自身是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：自己手卡数量比对方多
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较自己与对方的手卡数量，若自己较多则返回true
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
end
-- ②效果的发动准备：检查并获取场上可以变更表示形式的怪兽，并设置操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查场上是否存在可以变更表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有可以变更表示形式的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁中的操作信息：变更表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 过滤条件：表侧表示的昆虫族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- ②效果的处理：变更表示形式，改变其他昆虫族怪兽的属性和等级，并施加特殊召唤限制
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有可以变更表示形式的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 变更这些怪兽的表示形式（攻击表示变守备表示，守备表示变攻击表示）
	Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	-- 获取场上除这张卡以外的所有表侧表示的昆虫族怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 遍历这些昆虫族怪兽
		for tc in aux.Next(g) do
			-- 场上的其他的昆虫族怪兽的属性·等级变成和这张卡相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(c:GetAttribute())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetLevel()>0 then
				-- 场上的其他的昆虫族怪兽的属性·等级变成和这张卡相同。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CHANGE_LEVEL)
				e2:SetValue(c:GetLevel())
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
	-- 这个回合，自己不是昆虫族怪兽不能特殊召唤。③：这张卡被破坏的场合才能发动。从卡组把1只8星以上的昆虫族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册特殊召唤限制的效果
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制：不能特殊召唤昆虫族以外的怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end
-- 过滤条件：等级8以上的昆虫族怪兽且能加入手卡
function s.thfilter(c)
	return c:IsLevelAbove(8) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- ③效果的发动准备：检查卡组中是否存在满足条件的怪兽，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己卡组是否存在等级8以上的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：从卡组选择1只等级8以上的昆虫族怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
