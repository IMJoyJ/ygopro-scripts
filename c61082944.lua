--霊力回復薬
-- 效果：
-- 这个卡名在规则上也当作「凭依」卡使用。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地的魔法师族怪兽以及魔法卡之中让任意数量除外才能发动。自己场上的全部怪兽的攻击力上升除外数量×200，自己回复除外数量×400基本分。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡把魔法师族怪兽任意数量特殊召唤（相同属性最多1只）。
local s,id,o=GetID()
-- 初始化卡片效果，注册这张卡的发动效果以及墓地发动效果
function s.initial_effect(c)
	-- ①：从自己墓地的魔法师族怪兽以及魔法卡之中让任意数量除外才能发动。自己场上的全部怪兽的攻击力上升除外数量×200，自己回复除外数量×400基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	-- 设置发动时点条件：伤害步骤中仅能在伤害计算前发动
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
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤墓地中可作为代价除外的魔法卡或魔法师族怪兽
function s.cfilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsRace(RACE_SPELLCASTER)) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价处理：从自己墓地选任意数量的魔法师族怪兽或魔法卡除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己墓地是否存在可作为代价除外的魔法师族怪兽或魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取自己墓地中满足条件的魔法师族怪兽和魔法卡
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=sg:Select(tp,1,sg:GetCount(),nil)
	-- 将选中的卡片作为代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- ①效果的发动目标确认与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and e:IsCostChecked() end
	-- 设置回复基本分（除外数量×400）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel()*400)
end
-- ①效果的效果处理（场上全部怪兽攻击力上升除外数量×200，并回复除外数量×400基本分）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上全部表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local atk=e:GetLabel()
	if g:GetCount()==0 then return end
	local res=false
	-- 遍历自己场上的全部表侧表示怪兽
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
		-- 自己回复除外数量×400基本分
		Duel.Recover(tp,atk*400,REASON_EFFECT)
	end
end
-- 过滤手卡中可特殊召唤的魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标确认与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡中存在可特殊召唤的魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置从手卡特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的效果处理（从手卡把不同属性的魔法师族怪兽特殊召唤）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取主要怪兽区域可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡中可特殊召唤的魔法师族怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择最多到空位数且属性互不相同的怪兽组
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
	if sg then
		-- 将选中的魔法师族怪兽表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
