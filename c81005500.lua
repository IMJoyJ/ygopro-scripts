--お菓子の大精霊ウィーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。这张卡在自己场上表侧表示存在的场合，对方从以下效果选1个，自己让那个效果适用。
-- ●这张卡的攻击力上升自己墓地的不死族怪兽数量×800。
-- ●给与对方为自己墓地的不死族怪兽数量×500伤害。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从对方墓地把1只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（召唤·特召成功时发动，对方选择一项适用）和②效果（被破坏时特召对方墓地怪兽）。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。这张卡在自己场上表侧表示存在的场合，对方从以下效果选1个，自己让那个效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升或者给予伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从对方墓地把1只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"对方墓地怪兽在自己场上特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动准备（Target）函数，检查自己墓地是否存在不死族怪兽。
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_ZOMBIE) end
end
-- ①效果的处理（Operation）函数，若此卡在场上表侧表示存在，则由对方选择一项效果并适用。
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	-- 获取自己墓地的不死族怪兽数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_ZOMBIE)
	if ct==0 then return end
	-- 让对方玩家从“攻击力上升”和“给予伤害”中选择一个效果。
	local res=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"攻击力上升/伤害给与"
	if res==0 then
		-- ●这张卡的攻击力上升自己墓地的不死族怪兽数量×800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*800)
		c:RegisterEffect(e1)
	elseif res==1 then
		-- 给与对方为自己墓地的不死族怪兽数量×500伤害。
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数，检查此卡是否被战斗或效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：可以被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备（Target）函数，检查自己场上是否有空位以及对方墓地是否有可特殊召唤的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理（Operation）函数，从对方墓地选择1只怪兽在自己场上特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从对方墓地选择1只满足特殊召唤条件且不受王家之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
