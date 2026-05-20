--ドラゴン・復活の狂奏
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有魔法师族怪兽存在的场合，以包含龙族通常怪兽的自己墓地最多2只龙族怪兽为对象才能发动。那些怪兽特殊召唤。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
function c71867500.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有魔法师族怪兽存在的场合，以包含龙族通常怪兽的自己墓地最多2只龙族怪兽为对象才能发动。那些怪兽特殊召唤。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,71867500+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c71867500.condition)
	e1:SetTarget(c71867500.target)
	e1:SetOperation(c71867500.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的魔法师族怪兽
function c71867500.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件：自己场上有魔法师族怪兽存在
function c71867500.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c71867500.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中可以特殊召唤的龙族怪兽
function c71867500.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：墓地中可以特殊召唤的龙族通常怪兽
function c71867500.nfilter(c,e,tp)
	return c71867500.filter(c,e,tp) and c:IsType(TYPE_NORMAL)
end
-- 效果发动时的对象选择与合法性检测
function c71867500.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查怪兽区是否有空位，且墓地是否存在至少1只可特殊召唤的龙族通常怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c71867500.nfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只龙族通常怪兽作为效果的对象
	local g1=Duel.SelectTarget(tp,c71867500.nfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查墓地中是否存在除已选择的卡以外的、可特殊召唤的龙族怪兽
		and Duel.IsExistingTarget(c71867500.filter,tp,LOCATION_GRAVE,0,1,g1,e,tp)
		-- 询问玩家是否继续选择第2只怪兽作为对象
		and Duel.SelectYesNo(tp,aux.Stringid(71867500,0)) then  --"是否继续选择？"
		-- 提示玩家选择第2只特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地中第2只龙族怪兽作为效果的对象
		local g2=Duel.SelectTarget(tp,c71867500.filter,tp,LOCATION_GRAVE,0,1,1,g1,e,tp)
		g1:Merge(g2)
	end
	-- 设置连锁信息，表明此效果包含特殊召唤所选对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,g1:GetCount(),0,0)
end
-- 效果处理的执行函数
function c71867500.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 那些怪兽特殊召唤。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册“对方受到的全部伤害变成0”的玩家效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册“对方受到的效果伤害变成0”的玩家效果
		Duel.RegisterEffect(e2,tp)
	end
	-- 效果处理时，再次获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<1 then return end
	-- 获取当前连锁中仍与此效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>ct or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,1,1,nil)
	end
	-- 将选中的怪兽在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
