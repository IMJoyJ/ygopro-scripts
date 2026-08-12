--霊力回復薬
-- 效果：
-- 这个卡名在规则上也当作「凭依」卡使用。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地的魔法师族怪兽以及魔法卡之中让任意数量除外才能发动。自己场上的全部怪兽的攻击力上升除外数量×200，自己回复除外数量×400基本分。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡把魔法师族怪兽任意数量特殊召唤（相同属性最多1只）。
local s,id,o=GetID()
-- 初始化卡片效果注册
function s.initial_effect(c)
	-- ①：从自己墓地的魔法师族怪兽以及魔法卡之中让任意数量除外才能发动。自己场上的全部怪兽的攻击力上升除外数量×200，自己回复除外数量×400基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	-- 设置效果①发动条件：不能在伤害步骤伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡把魔法师族怪兽任意数量特殊召唤（相同属性最多1只）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置效果②的发动Cost：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost过滤函数，筛选自己墓地中可以除外的魔法师族怪兽或魔法卡
function s.cfilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsRace(RACE_SPELLCASTER)) and c:IsAbleToRemoveAsCost()
end
-- 效果①的Cost函数，处理选择任意数量的卡片除外，并记录除外卡片的数量
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以除外的魔法师族怪兽或魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取自己墓地中所有满足除外条件的魔法师族怪兽和魔法卡
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=sg:Select(tp,1,sg:GetCount(),nil)
	-- 将选中的卡片以表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果①的target函数，检查己方场上是否有表侧表示的怪兽，并设置基本分回复的连锁操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在表侧表示的怪兽，且检查代价已成功支付
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and e:IsCostChecked() end
	-- 设置基本分回复操作信息，表示玩家回复除外数量×400的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel()*400)
end
-- 效果①的operation函数，处理自己场上怪兽攻击力上升以及己方基本分回复的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local atk=e:GetLabel()
	if g:GetCount()==0 then return end
	local res=false
	-- 遍历每一只表侧表示的怪兽
	for tc in aux.Next(g) do
		-- 自己场上的全部怪兽的攻击力上升除外数量×200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk*200)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			res=true
		end
	end
	if res then
		-- 使己方玩家回复除外卡片数量×400的基本分
		Duel.Recover(tp,atk*400,REASON_EFFECT)
	end
end
-- 效果②的特殊召唤过滤函数，筛选手卡中的魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的target函数，检查场上空余区域及手卡是否有魔法师族怪兽，并设置特殊召唤的连锁操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息，表示从手卡特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的operation函数，处理从手卡特殊召唤任意数量属性不同的魔法师族怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡中所有满足条件的魔法师族怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选取属性各不相同的怪兽组合
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
	if sg:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
