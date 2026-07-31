--Imposter Shift
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动、对方怪兽发动取对象效果时除外墓地卡或无效效果、以及除外墓地怪兽特召衍生物效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方在怪兽区域发动的怪兽效果取场上的卡为对象时，对方可以选自身墓地1张卡除外。不除外的场合，那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只怪兽除外才能发动。把1只等级和除外怪兽相同的「Imposter Token」（念动力族·地·攻/守800）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.tokencost)
	e3:SetTarget(s.tokentg)
	e3:SetOperation(s.tokenop)
	c:RegisterEffect(e3)
end
-- 目标过滤条件：在场上且在连锁中取为对象，且不在发动效果的怪兽所在纵列
function s.tfilter(c,rc,ev)
	return c:IsOnField() and c:IsRelateToChain(ev) and not rc:GetColumnGroup():IsContains(c)
end
-- ①效果触发条件：对方在怪兽区发动怪兽效果且取场上非同纵列的卡为对象
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取引发连锁的效果的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取引发连锁的效果的对象卡组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local rc=re:GetHandler()
	-- 判断是否满足效果无效处理的触发条件
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
		and rc:IsRelateToChain(ev) and rc:IsControler(rp) and rc:IsType(TYPE_MONSTER)
		and tg and tg:IsExists(s.tfilter,1,rc,rc,ev)
end
-- ①效果处理：允许对方从墓地除外1张卡，若对方不除外则无效该效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local res=false
	-- 检查对方墓地是否有可除外的卡并询问对方是否除外
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil,1-tp) and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		-- 提示对方玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 由对方从其墓地选择1张可以除外的卡
		local g=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,1,nil,tp)
		-- 将对方选择的卡除外
		if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT,1-tp)>0 then
			res=true
		end
	end
	if not res then
		-- 显示卡片效果发动提示
		Duel.Hint(HINT_CARD,0,id)
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- Cost过滤条件：墓地中等级1以上可除外的怪兽，且玩家能特殊召唤对应等级的衍生物
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsLevelAbove(1) and c:IsFaceupEx()
		-- 检查玩家是否能在场上特殊召唤对应等级的「Imposter Token」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,c:GetLevel(),RACE_PSYCHO,ATTRIBUTE_EARTH)
end
-- ②效果发动Cost：从墓地除外1只怪兽并记录其等级
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地是否存在满足Cost条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c,tp) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c,tp):GetFirst()
	e:SetLabel(tc:GetLevel())
	-- 将选中的怪兽除外作为Cost
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
-- ②效果发动准备：检查怪兽区域空位并设置召唤衍生物的操作信息
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域存在空位
	if chk==0 then return e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁操作信息：生成1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：生成并特殊召唤1只相同等级的「Imposter Token」
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否能特殊召唤记录等级的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,lv,RACE_PSYCHO,ATTRIBUTE_EARTH) then
		-- 生成「Imposter Token」卡片对象
		local tk=Duel.CreateToken(tp,id+o)
		-- 把1只等级和除外怪兽相同的「Imposter Token」（念动力族·地·攻/守800）特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(lv)
		tk:RegisterEffect(e1,true)
		-- 将「Imposter Token」表侧表示特殊召唤
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
	end
end
